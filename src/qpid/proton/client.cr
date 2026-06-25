require "socket"

module Qpid
  module Proton
    class IncomingMessage < Handle
      getter message : Message
      getter delivery : Delivery?

      def initialize(@message : Message, @delivery : Delivery? = nil)
        @settled = @delivery.nil?
      end

      def accept(settle = true) : self
        @delivery.try &.accept
        self.settle if settle
        self
      end

      def reject(settle = true) : self
        @delivery.try &.reject
        self.settle if settle
        self
      end

      def release(settle = true) : self
        @delivery.try &.release
        self.settle if settle
        self
      end

      def settle : self
        unless @settled
          @delivery.try &.settle
          @settled = true
        end
        self
      end

      def settled? : Bool
        @settled
      end
    end

    class Client < Handle
      alias IOFactory = String, Int32, Time::Span -> IO

      DEFAULT_PORT                    = 5672
      DEFAULT_TIMEOUT                 = 10.seconds
      DEFAULT_SESSION_INCOMING_WINDOW = 1024_u32

      getter host : String
      getter port : Int32
      getter container_id : String
      getter connection : Connection?
      getter transport : Transport?

      @driver : ConnectionDriver?
      @io : IO?
      @io_factory : IOFactory?
      @username : String?
      @password : String?
      @virtual_host : String?
      @sasl_allowed_mechanisms : String?
      @allow_insecure_mechanisms : Bool
      @externally_encrypted : Bool
      @last_error : Error?

      def initialize(@host = "localhost", @port = DEFAULT_PORT, username : String? = nil,
                     password : String? = nil, virtual_host : String? = nil,
                     container_id : String? = nil, sasl_allowed_mechanisms : String? = nil,
                     allow_insecure_mechanisms = false, io_factory = nil,
                     externally_encrypted = false)
        @username = username
        @password = password
        @virtual_host = virtual_host
        @sasl_allowed_mechanisms = sasl_allowed_mechanisms
        @allow_insecure_mechanisms = allow_insecure_mechanisms
        @io_factory = wrap_io_factory(io_factory)
        @externally_encrypted = externally_encrypted
        @container_id = container_id || "qpid-proton-cr-#{Process.pid}-#{Time.utc.to_unix_ms}"
        driver = ConnectionDriver.new
        @driver = driver
        @io = nil
        @connection = driver.connection
        @transport = driver.transport
        @connected = false
        @closed = false
        @freed = false
        @last_error = nil
        @sessions = [] of Session
        @senders = {} of String => SenderState
        @receivers = {} of String => ReceiverState
        @receiver_links = {} of UInt64 => ReceiverState
        @delivery_tags = 0_u64
        @link_ids = 0_u64
      end

      def self.open(host = "localhost", port = DEFAULT_PORT, username : String? = nil,
                    password : String? = nil, virtual_host : String? = nil,
                    container_id : String? = nil, timeout = DEFAULT_TIMEOUT,
                    sasl_allowed_mechanisms : String? = nil,
                    allow_insecure_mechanisms = false, io_factory = nil,
                    externally_encrypted = false, &)
        client = new(
          host,
          port,
          username,
          password,
          virtual_host,
          container_id,
          sasl_allowed_mechanisms,
          allow_insecure_mechanisms,
          io_factory,
          externally_encrypted
        )
        client.connect(timeout)
        begin
          yield client
        ensure
          client.close
        end
      end

      def self.address(host : String, port : Int | String = DEFAULT_PORT) : String
        "#{host}:#{port}"
      end

      def finalize
        free_driver
      end

      def connected? : Bool
        @connected && !@closed
      end

      def closed? : Bool
        @closed
      end

      def connect(timeout = DEFAULT_TIMEOUT) : self
        return self if connected?
        raise Error.new("Client has been closed") if @freed

        connection = @connection || raise Error.new("Client has no connection")
        io = open_io(timeout)
        @io = io

        connection.container = @container_id
        connection.hostname = @virtual_host || @host
        connection.user = @username.not_nil! if @username
        connection.password = @password.not_nil! if @password
        configure_sasl

        unless pump_until(timeout) { @connected || @closed }
          raise Error.new("Timed out connecting to #{@host}:#{@port}")
        end

        raise @last_error.not_nil! unless @connected
        self
      rescue ex : Socket::Error
        free_driver
        raise Error.new("Failed to connect to #{@host}:#{@port}: #{ex.message}")
      end

      def close(timeout = 5.seconds) : Nil
        return if @freed

        if driver = @driver
          if @connected && !@closed
            @connection.try &.close
            pump_until(timeout) { @closed || driver.finished? } rescue nil
          end

          driver.close rescue nil
          pump_until(100.milliseconds) { driver.finished? } rescue nil
          free_driver
        end

        @closed = true
        @connected = false
        @freed = true
      end

      def publish(address : String, body : String, timeout = DEFAULT_TIMEOUT, confirm = true) : UInt64
        message = Message.new
        message.address = address
        message.body = body
        publish(address, message, timeout, confirm)
      end

      def publish(address : String, body : Bytes, timeout = DEFAULT_TIMEOUT, confirm = true) : UInt64
        message = Message.new
        message.address = address
        message.body = body
        publish(address, message, timeout, confirm)
      end

      def publish(address : String, message : Message, timeout = DEFAULT_TIMEOUT, confirm = true) : UInt64
        ensure_connected(timeout)
        sender = ensure_sender(address, timeout)

        unless pump_until(timeout) { sender.link.credit > 0 || @closed }
          raise Error.new("Timed out waiting for sender credit on #{address}")
        end

        delivery = sender.link.delivery(next_delivery_tag)
        sent = Lib.pn_message_send(message.raw, sender.link.raw, Pointer(Lib::RWBytes).null)
        Proton.check!(sent, message.error, "pn_message_send")

        if confirm
          unless pump_until(timeout) { delivery.updated? || delivery.settled? || @closed }
            raise Error.new("Timed out waiting for broker disposition on #{address}")
          end

          state = delivery.remote_state
          delivery.settle
          raise Error.new("Broker rejected published message on #{address}: #{DispositionState.name(state)}") unless state == Lib::ACCEPTED
          state
        else
          pump_until(timeout) { !delivery.buffered? || @closed } rescue nil
          delivery.settle unless delivery.settled?
          delivery.remote_state
        end
      end

      def receive(address : String, timeout = DEFAULT_TIMEOUT, credit = 10) : Message?
        receive_delivery(address, timeout, credit, auto_accept: true).try &.message
      end

      def receive_delivery(address : String, timeout = DEFAULT_TIMEOUT, credit = 10, auto_accept = false) : IncomingMessage?
        ensure_connected(timeout)
        receiver = ensure_receiver(address, credit, auto_accept, timeout)
        receiver.auto_accept = auto_accept

        unless receiver.messages.empty?
          return shift_message(receiver)
        end

        return nil unless pump_until(timeout) { !receiver.messages.empty? || @closed }
        raise @last_error.not_nil! if @closed && @last_error

        shift_message(receiver)
      end

      def consume(address : String, credit = 10, timeout = DEFAULT_TIMEOUT, &)
        loop do
          message = receive(address, timeout, credit)
          break unless message

          yield message
        end
      end

      def consume_delivery(address : String, credit = 10, timeout = DEFAULT_TIMEOUT, &)
        loop do
          incoming = receive_delivery(address, timeout, credit, auto_accept: false)
          break unless incoming

          yield incoming
        end
      end

      private def ensure_connected(timeout : Time::Span) : Nil
        connect(timeout) unless connected?
      end

      private def configure_sasl : Nil
        transport = @transport || raise Error.new("Client has no transport")
        sasl = transport.sasl
        sasl.allowed_mechanisms = @sasl_allowed_mechanisms.not_nil! if @sasl_allowed_mechanisms
        sasl.allow_insecure_mechanisms = @allow_insecure_mechanisms || @externally_encrypted
      end

      private def driver : ConnectionDriver
        @driver || raise Error.new("Client has been closed")
      end

      private def io : IO
        @io || raise Error.new("Client is not connected")
      end

      private def free_driver : Nil
        return if @freed

        @io.try &.close rescue nil
        @io = nil
        @driver.try &.destroy
        @driver = nil
        @connection = nil
        @transport = nil

        @closed = true
        @connected = false
        @freed = true
      end

      private def ensure_sender(address : String, timeout : Time::Span) : SenderState
        if sender = @senders[address]?
          return sender
        end

        connection = @connection || raise Error.new("Client is not connected")
        session = open_session(connection)
        link = session.sender(next_link_name("sender"))
        link.target.address = address
        link.open

        sender = SenderState.new(address, session, link)
        @senders[address] = sender

        unless pump_until(timeout) { sender.remote_open? || link.remote_active? || @closed }
          raise Error.new("Timed out opening sender link for #{address}")
        end
        raise @last_error.not_nil! if @closed && @last_error

        sender
      end

      private def ensure_receiver(address : String, credit : Int32, auto_accept : Bool, timeout : Time::Span) : ReceiverState
        if receiver = @receivers[address]?
          receiver.link.flow(credit) if receiver.link.credit < credit
          return receiver
        end

        connection = @connection || raise Error.new("Client is not connected")
        session = open_session(connection)
        link = session.receiver(next_link_name("receiver"))
        link.source.address = address
        link.open

        receiver = ReceiverState.new(address, session, link, auto_accept)
        @receivers[address] = receiver
        @receiver_links[link.raw.address] = receiver

        unless pump_until(timeout) { receiver.remote_open? || link.remote_active? || @closed }
          raise Error.new("Timed out opening receiver link for #{address}")
        end
        raise @last_error.not_nil! if @closed && @last_error

        link.flow(credit)
        receiver
      end

      private def open_session(connection : Connection) : Session
        session = connection.session
        session.set_incoming_window(DEFAULT_SESSION_INCOMING_WINDOW)
        session.open
        @sessions << session
        session
      end

      private def shift_message(receiver : ReceiverState) : IncomingMessage?
        message = receiver.messages.shift?
        receiver.link.flow(1) if message
        message
      end

      private def pump_until(timeout : Time::Span, &condition : -> Bool) : Bool
        return true if condition.call

        deadline = Time.instant + timeout

        loop do
          return true if condition.call

          progressed = process_events
          progressed = flush_output(deadline) || progressed
          progressed = process_events || progressed

          return true if condition.call
          raise @last_error.not_nil! if @closed && @last_error

          remaining = deadline - Time.instant
          return false if remaining <= Time::Span.zero

          unless progressed
            return false unless read_input(remaining)
          end
        end
      end

      private def process_events : Bool
        progressed = false

        while event = driver.next_event
          progressed = true
          handle_event(event)
        end

        progressed
      end

      private def flush_output(deadline : Time::Instant) : Bool
        progressed = false

        loop do
          output = driver.pending_output
          break if output.empty?

          remaining = deadline - Time.instant
          break if remaining <= Time::Span.zero

          output_io = io
          set_write_timeout(output_io, remaining)
          output_io.write(output)
          driver.write_done(output.size)
          progressed = true
        end

        progressed
      rescue IO::TimeoutError
        return false
      rescue ex : IO::Error | Socket::Error
        fail_io("Socket write failed", ex)
        return false
      end

      private def read_input(timeout : Time::Span) : Bool
        input_io = io
        set_read_timeout(input_io, timeout)

        buffer = Lib.pn_connection_driver_read_buffer(driver.raw)
        return false if buffer.size == 0 || buffer.start.null?

        count = input_io.read(Slice.new(buffer.start, buffer.size.to_i))

        if count == 0
          return handle_eof
        else
          Lib.pn_connection_driver_read_done(driver.raw, count)
          return true
        end
      rescue IO::TimeoutError
        return false
      rescue ex : IO::Error | Socket::Error
        fail_io("Socket read failed", ex)
        return false
      end

      private def handle_eof : Bool
        driver.read_close
        true
      end

      private def handle_event(event : Event) : Nil
        case event.type
        when Lib::EventType::ConnectionInit
          event.connection.try &.open
        when Lib::EventType::ConnectionRemoteOpen
          @connected = true
        when Lib::EventType::ConnectionRemoteClose
          remember_condition(event.condition, "Connection closed by remote peer")
          event.connection.try &.close
        when Lib::EventType::TransportHeadClosed, Lib::EventType::TransportTailClosed
          driver.close if driver.read_closed? && driver.write_closed?
        when Lib::EventType::TransportError
          remember_condition(event.condition, "Transport error")
        when Lib::EventType::TransportClosed
          @closed = true
          @connected = false
        when Lib::EventType::LinkRemoteOpen
          handle_link_remote_open(event)
        when Lib::EventType::Delivery
          handle_delivery(event)
        end
      end

      private def wrap_io_factory(io_factory) : IOFactory?
        io_factory.try do |factory|
          ->(host : String, port : Int32, timeout : Time::Span) { factory.call(host, port, timeout).as(IO) }
        end
      end

      private def open_io(timeout : Time::Span) : IO
        if factory = @io_factory
          factory.call(@host, @port, timeout)
        else
          TCPSocket.new(@host, @port, nil, timeout).as(IO)
        end.tap do |opened_io|
          set_read_timeout(opened_io, timeout)
          set_write_timeout(opened_io, timeout)
        end
      end

      private def set_read_timeout(io : IO, timeout : Time::Span) : Nil
        if io.responds_to?(:read_timeout=)
          io.read_timeout = timeout
        end
      end

      private def set_write_timeout(io : IO, timeout : Time::Span) : Nil
        if io.responds_to?(:write_timeout=)
          io.write_timeout = timeout
        end
      end

      private def handle_link_remote_open(event : Event) : Nil
        link = event.link
        return unless link

        if sender = @senders.values.find { |state| state.link.raw == link.raw }
          sender.remote_open = true
        elsif receiver = @receiver_links[link.raw.address]?
          receiver.remote_open = true
        end
      end

      private def fail_io(prefix : String, exception : Exception) : NoReturn
        @last_error = Error.new("#{prefix}: #{exception.message}") unless @last_error
        @closed = true
        @connected = false
        driver.close rescue nil
        raise @last_error.not_nil!
      end

      private def handle_delivery(event : Event) : Nil
        delivery = event.delivery
        return unless delivery

        if delivery.readable?
          handle_readable_delivery(delivery)
        end
      end

      private def handle_readable_delivery(delivery : Delivery) : Nil
        return if delivery.partial?

        link = delivery.link
        receiver = @receiver_links[link.raw.address]?
        return unless receiver

        if delivery.aborted?
          link.advance
          delivery.settle
          return
        end

        memory = IO::Memory.new

        loop do
          pending = delivery.pending
          break if pending == 0

          buffer = Bytes.new(pending.to_i)
          received = Lib.pn_link_recv(link.raw, buffer.to_unsafe, buffer.size)
          break if received == Lib::EOS
          Proton.check!(received, link.error, "pn_link_recv")
          break if received == 0

          memory.write(buffer[0, received.to_i])
        end

        message = Message.decode(memory.to_slice)
        incoming = IncomingMessage.new(message, delivery)

        receiver.messages << incoming
        link.advance
        incoming.accept if receiver.auto_accept
      end

      private def remember_condition(condition : Condition?, fallback : String) : Nil
        return if @last_error

        if condition && condition.set?
          name = condition.name
          description = condition.description
          message = String.build do |io|
            io << fallback
            io << " (#{name})" if name
            io << ": #{description}" if description
          end
          @last_error = Error.new(message, name: name, detail: description)
        else
          @last_error = Error.new(fallback)
        end
      end

      private def next_delivery_tag : String
        @delivery_tags += 1
        "#{@container_id}-delivery-#{@delivery_tags}"
      end

      private def next_link_name(prefix : String) : String
        @link_ids += 1
        "#{@container_id}-#{prefix}-#{@link_ids}"
      end

      private class SenderState
        getter address : String
        getter session : Session
        getter link : Link
        property? remote_open = false

        def initialize(@address : String, @session : Session, @link : Link)
        end
      end

      private class ReceiverState
        getter address : String
        getter session : Session
        getter link : Link
        property auto_accept : Bool
        property? remote_open = false
        getter messages = Deque(IncomingMessage).new

        def initialize(@address : String, @session : Session, @link : Link, @auto_accept : Bool)
        end
      end

      private module DispositionState
        def self.name(state : UInt64) : String
          Proton.string_or_nil(Lib.pn_disposition_type_name(state)) || state.to_s
        end
      end
    end
  end
end
