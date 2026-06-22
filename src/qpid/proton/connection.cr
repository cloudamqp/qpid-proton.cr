module Qpid
  module Proton
    module EndpointState
      def local_uninitialized? : Bool
        (state & Lib::LOCAL_UNINIT) != 0
      end

      def local_active? : Bool
        (state & Lib::LOCAL_ACTIVE) != 0
      end

      def local_closed? : Bool
        (state & Lib::LOCAL_CLOSED) != 0
      end

      def remote_uninitialized? : Bool
        (state & Lib::REMOTE_UNINIT) != 0
      end

      def remote_active? : Bool
        (state & Lib::REMOTE_ACTIVE) != 0
      end

      def remote_closed? : Bool
        (state & Lib::REMOTE_CLOSED) != 0
      end
    end

    class Connection < Handle
      include EndpointState

      getter raw : Lib::Connection*

      def initialize
        @raw = Proton.check_pointer!(Lib.pn_connection, "pn_connection")
        @owned = true
        @owner = nil
      end

      protected def initialize(@raw : Lib::Connection*, @owned : Bool, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_connection")
      end

      def self.wrap(raw : Lib::Connection*, owner : Handle? = nil) : self
        new(raw, owned: false, owner: owner)
      end

      def finalize
        free
      end

      def free : Nil
        if @owned && !@raw.null?
          Lib.pn_connection_free(@raw)
          @raw = Pointer(Lib::Connection).null
        end
      end

      def error : Lib::Error*
        Lib.pn_connection_error(@raw)
      end

      def state : Int32
        Lib.pn_connection_state(@raw)
      end

      def open : self
        Lib.pn_connection_open(@raw)
        self
      end

      def close : self
        Lib.pn_connection_close(@raw)
        self
      end

      def reset : self
        Lib.pn_connection_reset(@raw)
        self
      end

      def condition : Condition
        Condition.wrap(Lib.pn_connection_condition(@raw), self)
      end

      def remote_condition : Condition
        Condition.wrap(Lib.pn_connection_remote_condition(@raw), self)
      end

      def container : String?
        Proton.string_or_nil(Lib.pn_connection_get_container(@raw))
      end

      def container=(value : String) : String
        Lib.pn_connection_set_container(@raw, value)
        value
      end

      def user : String?
        Proton.string_or_nil(Lib.pn_connection_get_user(@raw))
      end

      def user=(value : String) : String
        Lib.pn_connection_set_user(@raw, value)
        value
      end

      def password=(value : String) : String
        Lib.pn_connection_set_password(@raw, value)
        value
      end

      def authorization : String?
        Proton.string_or_nil(Lib.pn_connection_get_authorization(@raw))
      end

      def authorization=(value : String) : String
        Lib.pn_connection_set_authorization(@raw, value)
        value
      end

      def hostname : String?
        Proton.string_or_nil(Lib.pn_connection_get_hostname(@raw))
      end

      def hostname=(value : String) : String
        Lib.pn_connection_set_hostname(@raw, value)
        value
      end

      def remote_container : String?
        Proton.string_or_nil(Lib.pn_connection_remote_container(@raw))
      end

      def remote_hostname : String?
        Proton.string_or_nil(Lib.pn_connection_remote_hostname(@raw))
      end

      def session : Session
        Session.wrap(Proton.check_pointer!(Lib.pn_session(@raw), "pn_session"), self)
      end

      def sessions(state = 0)
        SessionIterator.new(self, state)
      end

      def collect(collector : Collector) : self
        Lib.pn_connection_collect(@raw, collector.raw)
        self
      end

      def collector : Collector?
        pointer = Lib.pn_connection_collector(@raw)
        pointer.null? ? nil : Collector.wrap(pointer, self)
      end

      def offered_capabilities : Data
        Data.wrap(Lib.pn_connection_offered_capabilities(@raw), self)
      end

      def desired_capabilities : Data
        Data.wrap(Lib.pn_connection_desired_capabilities(@raw), self)
      end

      def properties : Data
        Data.wrap(Lib.pn_connection_properties(@raw), self)
      end

      def remote_offered_capabilities : Data
        Data.wrap(Lib.pn_connection_remote_offered_capabilities(@raw), self)
      end

      def remote_desired_capabilities : Data
        Data.wrap(Lib.pn_connection_remote_desired_capabilities(@raw), self)
      end

      def remote_properties : Data
        Data.wrap(Lib.pn_connection_remote_properties(@raw), self)
      end

      def transport : Transport?
        pointer = Lib.pn_connection_transport(@raw)
        pointer.null? ? nil : Transport.wrap(pointer, self)
      end

      def wake : self
        Lib.pn_connection_wake(@raw)
        self
      end

      def write_flush : self
        Lib.pn_connection_write_flush(@raw)
        self
      end
    end
  end
end
