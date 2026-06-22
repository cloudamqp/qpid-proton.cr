module Qpid
  module Proton
    class Session < Handle
      include EndpointState

      getter raw : Lib::Session*

      protected def initialize(@raw : Lib::Session*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_session")
      end

      def self.wrap(raw : Lib::Session*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def state : Int32
        Lib.pn_session_state(@raw)
      end

      def error : Lib::Error*
        Lib.pn_session_error(@raw)
      end

      def open : self
        Lib.pn_session_open(@raw)
        self
      end

      def close : self
        Lib.pn_session_close(@raw)
        self
      end

      def condition : Condition
        Condition.wrap(Lib.pn_session_condition(@raw), self)
      end

      def remote_condition : Condition
        Condition.wrap(Lib.pn_session_remote_condition(@raw), self)
      end

      def connection : Connection
        Connection.wrap(Lib.pn_session_connection(@raw), self)
      end

      def sender(name : String) : Link
        Link.wrap(Proton.check_pointer!(Lib.pn_sender(@raw, name), "pn_sender"), self)
      end

      def receiver(name : String) : Link
        Link.wrap(Proton.check_pointer!(Lib.pn_receiver(@raw, name), "pn_receiver"), self)
      end

      def incoming_capacity : UInt64
        Lib.pn_session_get_incoming_capacity(@raw)
      end

      def incoming_capacity=(value : UInt64) : UInt64
        Lib.pn_session_set_incoming_capacity(@raw, value)
        value
      end

      def incoming_window : UInt32
        Lib.pn_session_incoming_window(@raw)
      end

      def incoming_window_lwm : UInt32
        Lib.pn_session_incoming_window_lwm(@raw)
      end

      def set_incoming_window(window : UInt32, low_water_mark : UInt32 = 0) : self
        Proton.check!(Lib.pn_session_set_incoming_window_and_lwm(@raw, window, low_water_mark), error, "pn_session_set_incoming_window_and_lwm")
        self
      end

      def remote_incoming_window : UInt32
        Lib.pn_session_remote_incoming_window(@raw)
      end

      def outgoing_window : UInt64
        Lib.pn_session_get_outgoing_window(@raw)
      end

      def outgoing_window=(value : UInt64) : UInt64
        Lib.pn_session_set_outgoing_window(@raw, value)
        value
      end

      def outgoing_bytes : UInt64
        Lib.pn_session_outgoing_bytes(@raw)
      end

      def incoming_bytes : UInt64
        Lib.pn_session_incoming_bytes(@raw)
      end
    end

    class SessionIterator
      include Iterator(Session)

      def initialize(@connection : Connection, @state : Int32)
        @current = Lib.pn_session_head(@connection.raw, @state)
      end

      def next
        return stop if @current.null?

        session = Session.wrap(@current, @connection)
        @current = Lib.pn_session_next(@current, @state)
        session
      end
    end
  end
end
