module Qpid
  module Proton
    class ConnectionDriver < Handle
      def initialize
        @driver = Lib::ConnectionDriver.new(
          connection: Pointer(Lib::Connection).null,
          transport: Pointer(Lib::Transport).null,
          collector: Pointer(Lib::Collector).null
        )
        @closed = false
        Proton.check!(Lib.pn_connection_driver_init(pointerof(@driver), Pointer(Lib::Connection).null, Pointer(Lib::Transport).null), context: "pn_connection_driver_init")
      end

      def finalize
        destroy
      end

      def destroy : Nil
        unless @closed
          Lib.pn_connection_driver_destroy(pointerof(@driver))
          @closed = true
        end
      end

      def raw : Lib::ConnectionDriver*
        pointerof(@driver)
      end

      def connection : Connection
        Connection.wrap(Proton.check_pointer!(@driver.connection, "pn_connection_driver.connection"), self)
      end

      def transport : Transport
        Transport.wrap(Proton.check_pointer!(@driver.transport, "pn_connection_driver.transport"), self)
      end

      def bind : self
        Proton.check!(Lib.pn_connection_driver_bind(raw), context: "pn_connection_driver_bind")
        self
      end

      def read(bytes : Bytes) : Int32
        total = 0

        while total < bytes.size
          buffer = Lib.pn_connection_driver_read_buffer_sized(raw, bytes.size - total)
          break if buffer.size == 0 || buffer.start.null?

          count = {bytes.size - total, buffer.size}.min
          buffer.start.copy_from(bytes.to_unsafe + total, count)
          Lib.pn_connection_driver_read_done(raw, count)
          total += count
        end

        total.to_i32
      end

      def read(string : String) : Int32
        read(string.to_slice)
      end

      def read_close : self
        Lib.pn_connection_driver_read_close(raw)
        self
      end

      def read_closed? : Bool
        Lib.pn_connection_driver_read_closed(raw)
      end

      def pending_output : Bytes
        Proton.bytes_to_slice(Lib.pn_connection_driver_write_buffer(raw))
      end

      def write_done(size : Int) : Bytes
        Proton.bytes_to_slice(Lib.pn_connection_driver_write_done(raw, size))
      end

      def write_close : self
        Lib.pn_connection_driver_write_close(raw)
        self
      end

      def write_closed? : Bool
        Lib.pn_connection_driver_write_closed(raw)
      end

      def close : self
        Lib.pn_connection_driver_close(raw)
        self
      end

      def next_event : Event?
        pointer = Lib.pn_connection_driver_next_event(raw)
        pointer.null? ? nil : Event.wrap(pointer, self)
      end

      def event? : Bool
        Lib.pn_connection_driver_has_event(raw)
      end

      def finished? : Bool
        Lib.pn_connection_driver_finished(raw)
      end

      def log(message : String) : self
        Lib.pn_connection_driver_log(raw, message)
        self
      end
    end
  end
end
