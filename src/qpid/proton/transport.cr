module Qpid
  module Proton
    class Transport < Handle
      getter raw : Lib::Transport*

      def initialize
        @raw = Proton.check_pointer!(Lib.pn_transport, "pn_transport")
        @owned = true
        @owner = nil
      end

      protected def initialize(@raw : Lib::Transport*, @owned : Bool, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_transport")
      end

      def self.wrap(raw : Lib::Transport*, owner : Handle? = nil) : self
        new(raw, owned: false, owner: owner)
      end

      def finalize
        free
      end

      def free : Nil
        if @owned && !@raw.null?
          Lib.pn_transport_free(@raw)
          @raw = Pointer(Lib::Transport).null
        end
      end

      def server : self
        Lib.pn_transport_set_server(@raw)
        self
      end

      def user : String?
        Proton.string_or_nil(Lib.pn_transport_get_user(@raw))
      end

      def require_auth=(value : Bool) : Bool
        Lib.pn_transport_require_auth(@raw, value)
        value
      end

      def authenticated? : Bool
        Lib.pn_transport_is_authenticated(@raw)
      end

      def require_encryption=(value : Bool) : Bool
        Lib.pn_transport_require_encryption(@raw, value)
        value
      end

      def encrypted? : Bool
        Lib.pn_transport_is_encrypted(@raw)
      end

      def condition : Condition
        Condition.wrap(Lib.pn_transport_condition(@raw), self)
      end

      def error : Lib::Error*
        Lib.pn_transport_error(@raw)
      end

      def bind(connection : Connection) : self
        Proton.check!(Lib.pn_transport_bind(@raw, connection.raw), error, "pn_transport_bind")
        self
      end

      def unbind : self
        Proton.check!(Lib.pn_transport_unbind(@raw), error, "pn_transport_unbind")
        self
      end

      def trace(flags : Int32) : self
        Lib.pn_transport_trace(@raw, flags)
        self
      end

      def log(message : String) : self
        Lib.pn_transport_log(@raw, message)
        self
      end

      def channel_max : UInt16
        Lib.pn_transport_get_channel_max(@raw)
      end

      def channel_max=(value : UInt16) : UInt16
        Proton.check!(Lib.pn_transport_set_channel_max(@raw, value), error, "pn_transport_set_channel_max")
        value
      end

      def remote_channel_max : UInt16
        Lib.pn_transport_remote_channel_max(@raw)
      end

      def max_frame : UInt32
        Lib.pn_transport_get_max_frame(@raw)
      end

      def max_frame=(value : UInt32) : UInt32
        Lib.pn_transport_set_max_frame(@raw, value)
        value
      end

      def remote_max_frame : UInt32
        Lib.pn_transport_get_remote_max_frame(@raw)
      end

      def idle_timeout : UInt32
        Lib.pn_transport_get_idle_timeout(@raw)
      end

      def idle_timeout=(value : UInt32) : UInt32
        Lib.pn_transport_set_idle_timeout(@raw, value)
        value
      end

      def remote_idle_timeout : UInt32
        Lib.pn_transport_get_remote_idle_timeout(@raw)
      end

      def input(bytes : Bytes) : Int64
        read = Lib.pn_transport_input(@raw, bytes.to_unsafe, bytes.size)
        Proton.check!(read, error, "pn_transport_input")
        read
      end

      def input(string : String) : Int64
        input(string.to_slice)
      end

      def pending : Int64
        value = Lib.pn_transport_pending(@raw)
        Proton.check!(value, error, "pn_transport_pending")
        value
      end

      def pending_output : Bytes
        count = pending
        return Bytes.empty if count == 0

        head = Lib.pn_transport_head(@raw)
        return Bytes.empty if head.null?

        Slice.new(head, count.to_i).dup
      end

      def pop(size : Int) : self
        Lib.pn_transport_pop(@raw, size)
        self
      end

      def output(max = 4096) : Bytes
        buffer = Bytes.new(max)
        written = Lib.pn_transport_output(@raw, buffer.to_unsafe, buffer.size)
        Proton.check!(written, error, "pn_transport_output")
        buffer[0, written.to_i].dup
      end

      def close_tail : self
        Proton.check!(Lib.pn_transport_close_tail(@raw), error, "pn_transport_close_tail")
        self
      end

      def close_head : self
        Proton.check!(Lib.pn_transport_close_head(@raw), error, "pn_transport_close_head")
        self
      end

      def quiesced? : Bool
        Lib.pn_transport_quiesced(@raw)
      end

      def head_closed? : Bool
        Lib.pn_transport_head_closed(@raw)
      end

      def tail_closed? : Bool
        Lib.pn_transport_tail_closed(@raw)
      end

      def closed? : Bool
        Lib.pn_transport_closed(@raw)
      end

      def tick(now : Int64) : Int64
        Lib.pn_transport_tick(@raw, now)
      end

      def frames_output : UInt64
        Lib.pn_transport_get_frames_output(@raw)
      end

      def frames_input : UInt64
        Lib.pn_transport_get_frames_input(@raw)
      end

      def connection : Connection?
        pointer = Lib.pn_transport_connection(@raw)
        pointer.null? ? nil : Connection.wrap(pointer, self)
      end

      def sasl : Sasl
        Sasl.wrap(Proton.check_pointer!(Lib.pn_sasl(@raw), "pn_sasl"), self)
      end
    end

    class Sasl < Handle
      getter raw : Lib::Sasl*

      protected def initialize(@raw : Lib::Sasl*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_sasl")
      end

      def self.wrap(raw : Lib::Sasl*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def self.extended? : Bool
        Lib.pn_sasl_extended
      end

      def outcome : Lib::SaslOutcome
        Lib.pn_sasl_outcome(@raw)
      end

      def user : String?
        Proton.string_or_nil(Lib.pn_sasl_get_user(@raw))
      end

      def authorization : String?
        Proton.string_or_nil(Lib.pn_sasl_get_authorization(@raw))
      end

      def mechanism : String?
        Proton.string_or_nil(Lib.pn_sasl_get_mech(@raw))
      end

      def allowed_mechanisms=(value : String) : String
        Lib.pn_sasl_allowed_mechs(@raw, value)
        value
      end

      def allow_insecure_mechanisms=(value : Bool) : Bool
        Lib.pn_sasl_set_allow_insecure_mechs(@raw, value)
        value
      end

      def allow_insecure_mechanisms? : Bool
        Lib.pn_sasl_get_allow_insecure_mechs(@raw)
      end

      def config_name=(value : String) : String
        Lib.pn_sasl_config_name(@raw, value)
        value
      end

      def config_path=(value : String) : String
        Lib.pn_sasl_config_path(@raw, value)
        value
      end
    end
  end
end
