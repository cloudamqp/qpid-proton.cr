module Qpid
  module Proton
    class Message < Handle
      getter raw : Lib::Message*

      def initialize
        @raw = Proton.check_pointer!(Lib.pn_message, "pn_message")
        @owned = true
        @owner = nil
      end

      protected def initialize(@raw : Lib::Message*, @owned : Bool, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_message")
      end

      def self.wrap(raw : Lib::Message*, owner : Handle? = nil) : self
        new(raw, owned: false, owner: owner)
      end

      def self.decode(bytes : Bytes) : self
        message = new
        message.decode(bytes)
        message
      end

      def self.decode(string : String) : self
        decode(string.to_slice)
      end

      def finalize
        free
      end

      def free : Nil
        if @owned && !@raw.null?
          Lib.pn_message_free(@raw)
          @raw = Pointer(Lib::Message).null
        end
      end

      def error : Lib::Error*
        Lib.pn_message_error(@raw)
      end

      def errno : Int32
        Lib.pn_message_errno(@raw)
      end

      def clear : Nil
        Lib.pn_message_clear(@raw)
      end

      def inferred? : Bool
        Lib.pn_message_is_inferred(@raw)
      end

      def inferred=(value : Bool) : Bool
        check Lib.pn_message_set_inferred(@raw, value), "pn_message_set_inferred"
        value
      end

      def durable? : Bool
        Lib.pn_message_is_durable(@raw)
      end

      def durable=(value : Bool) : Bool
        check Lib.pn_message_set_durable(@raw, value), "pn_message_set_durable"
        value
      end

      def priority : UInt8
        Lib.pn_message_get_priority(@raw)
      end

      def priority=(value : UInt8) : UInt8
        check Lib.pn_message_set_priority(@raw, value), "pn_message_set_priority"
        value
      end

      def ttl : UInt32
        Lib.pn_message_get_ttl(@raw)
      end

      def ttl=(value : UInt32) : UInt32
        check Lib.pn_message_set_ttl(@raw, value), "pn_message_set_ttl"
        value
      end

      def first_acquirer? : Bool
        Lib.pn_message_is_first_acquirer(@raw)
      end

      def first_acquirer=(value : Bool) : Bool
        check Lib.pn_message_set_first_acquirer(@raw, value), "pn_message_set_first_acquirer"
        value
      end

      def delivery_count : UInt32
        Lib.pn_message_get_delivery_count(@raw)
      end

      def delivery_count=(value : UInt32) : UInt32
        check Lib.pn_message_set_delivery_count(@raw, value), "pn_message_set_delivery_count"
        value
      end

      def user_id : Bytes
        Proton.bytes_to_slice(Lib.pn_message_get_user_id(@raw))
      end

      def user_id=(value : Bytes) : Bytes
        check Lib.pn_message_set_user_id(@raw, Proton.pn_bytes(value)), "pn_message_set_user_id"
        value
      end

      def address : String?
        Proton.string_or_nil(Lib.pn_message_get_address(@raw))
      end

      def address=(value : String?) : String?
        check Lib.pn_message_set_address(@raw, string_pointer(value)), "pn_message_set_address"
        value
      end

      def subject : String?
        Proton.string_or_nil(Lib.pn_message_get_subject(@raw))
      end

      def subject=(value : String?) : String?
        check Lib.pn_message_set_subject(@raw, string_pointer(value)), "pn_message_set_subject"
        value
      end

      def reply_to : String?
        Proton.string_or_nil(Lib.pn_message_get_reply_to(@raw))
      end

      def reply_to=(value : String?) : String?
        check Lib.pn_message_set_reply_to(@raw, string_pointer(value)), "pn_message_set_reply_to"
        value
      end

      def content_type : String?
        Proton.string_or_nil(Lib.pn_message_get_content_type(@raw))
      end

      def content_type=(value : String?) : String?
        check Lib.pn_message_set_content_type(@raw, string_pointer(value)), "pn_message_set_content_type"
        value
      end

      def content_encoding : String?
        Proton.string_or_nil(Lib.pn_message_get_content_encoding(@raw))
      end

      def content_encoding=(value : String?) : String?
        check Lib.pn_message_set_content_encoding(@raw, string_pointer(value)), "pn_message_set_content_encoding"
        value
      end

      def expiry_time_ms : Int64
        Lib.pn_message_get_expiry_time(@raw)
      end

      def expiry_time_ms=(value : Int64) : Int64
        check Lib.pn_message_set_expiry_time(@raw, value), "pn_message_set_expiry_time"
        value
      end

      def creation_time_ms : Int64
        Lib.pn_message_get_creation_time(@raw)
      end

      def creation_time_ms=(value : Int64) : Int64
        check Lib.pn_message_set_creation_time(@raw, value), "pn_message_set_creation_time"
        value
      end

      def group_id : String?
        Proton.string_or_nil(Lib.pn_message_get_group_id(@raw))
      end

      def group_id=(value : String?) : String?
        check Lib.pn_message_set_group_id(@raw, string_pointer(value)), "pn_message_set_group_id"
        value
      end

      def group_sequence : UInt32
        Lib.pn_message_get_group_sequence(@raw)
      end

      def group_sequence=(value : UInt32) : UInt32
        check Lib.pn_message_set_group_sequence(@raw, value), "pn_message_set_group_sequence"
        value
      end

      def reply_to_group_id : String?
        Proton.string_or_nil(Lib.pn_message_get_reply_to_group_id(@raw))
      end

      def reply_to_group_id=(value : String?) : String?
        check Lib.pn_message_set_reply_to_group_id(@raw, string_pointer(value)), "pn_message_set_reply_to_group_id"
        value
      end

      def id : Data
        Data.wrap(Lib.pn_message_id(@raw), self)
      end

      def correlation_id : Data
        Data.wrap(Lib.pn_message_correlation_id(@raw), self)
      end

      def instructions : Data
        Data.wrap(Lib.pn_message_instructions(@raw), self)
      end

      def annotations : Data
        Data.wrap(Lib.pn_message_annotations(@raw), self)
      end

      def properties : Data
        Data.wrap(Lib.pn_message_properties(@raw), self)
      end

      def body : Data
        Data.wrap(Lib.pn_message_body(@raw), self)
      end

      def body=(value : String) : String
        body.clear
        body.put_string(value)
        value
      end

      def body=(value : Bytes) : Bytes
        body.clear
        body.put_binary(value)
        value
      end

      def body_string : String?
        data = body
        data.rewind
        return nil unless data.next

        case data.type
        when Lib::Type::String, Lib::Type::Symbol
          data.string
        else
          nil
        end
      end

      def decode(bytes : Bytes) : self
        check Lib.pn_message_decode(@raw, bytes.to_unsafe, bytes.size), "pn_message_decode"
        self
      end

      def decode(string : String) : self
        decode(string.to_slice)
      end

      def encode : Bytes
        capacity = 1024

        loop do
          buffer = Bytes.new(capacity)
          used = capacity.to_u64
          code = Lib.pn_message_encode(@raw, buffer.to_unsafe, pointerof(used))

          return buffer[0, used.to_i].dup if code == Lib::OK

          if code == Lib::OVERFLOW
            capacity *= 2
            next
          end

          check code, "pn_message_encode"
        end
      end

      def to_data : Data
        data = Data.new
        check Lib.pn_message_data(@raw, data.raw), "pn_message_data"
        data
      end

      private def check(code : Int, context : String) : Nil
        Proton.check!(code, error, context)
      end

      private def string_pointer(value : String?) : UInt8*
        value ? value.to_unsafe : Pointer(UInt8).null
      end
    end
  end
end
