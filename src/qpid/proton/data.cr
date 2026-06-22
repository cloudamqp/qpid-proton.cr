module Qpid
  module Proton
    class Data < Handle
      alias Scalar = Nil | Bool | UInt8 | Int8 | UInt16 | Int16 | UInt32 | Int32 | UInt64 | Int64 | Float32 | Float64 | String | Bytes

      getter raw : Lib::Data*

      def initialize(capacity = 0)
        @raw = Proton.check_pointer!(Lib.pn_data(capacity), "pn_data")
        @owned = true
        @owner = nil
      end

      protected def initialize(@raw : Lib::Data*, @owned : Bool, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_data")
      end

      def self.wrap(raw : Lib::Data*, owner : Handle? = nil) : self
        new(raw, owned: false, owner: owner)
      end

      def finalize
        free
      end

      def free : Nil
        if @owned && !@raw.null?
          Lib.pn_data_free(@raw)
          @raw = Pointer(Lib::Data).null
        end
      end

      def error : Lib::Error*
        Lib.pn_data_error(@raw)
      end

      def errno : Int32
        Lib.pn_data_errno(@raw)
      end

      def clear : Nil
        Lib.pn_data_clear(@raw)
      end

      def size : Int32
        Lib.pn_data_size(@raw).to_i32
      end

      def rewind : Nil
        Lib.pn_data_rewind(@raw)
      end

      def next : Bool
        Lib.pn_data_next(@raw)
      end

      def previous : Bool
        Lib.pn_data_prev(@raw)
      end

      def enter : Bool
        Lib.pn_data_enter(@raw)
      end

      def exit : Bool
        Lib.pn_data_exit(@raw)
      end

      def type : Lib::Type
        Lib.pn_data_type(@raw)
      end

      def type_name : String
        Proton.string_or_nil(Lib.pn_type_name(type)) || "unknown"
      end

      def each_child(&)
        rewind
        while self.next
          yield self
        end
      end

      def put(value : Nil) : self
        check Lib.pn_data_put_null(@raw), "pn_data_put_null"
        self
      end

      def put(value : Bool) : self
        check Lib.pn_data_put_bool(@raw, value), "pn_data_put_bool"
        self
      end

      def put(value : UInt8) : self
        check Lib.pn_data_put_ubyte(@raw, value), "pn_data_put_ubyte"
        self
      end

      def put(value : Int8) : self
        check Lib.pn_data_put_byte(@raw, value), "pn_data_put_byte"
        self
      end

      def put(value : UInt16) : self
        check Lib.pn_data_put_ushort(@raw, value), "pn_data_put_ushort"
        self
      end

      def put(value : Int16) : self
        check Lib.pn_data_put_short(@raw, value), "pn_data_put_short"
        self
      end

      def put(value : UInt32) : self
        check Lib.pn_data_put_uint(@raw, value), "pn_data_put_uint"
        self
      end

      def put(value : Int32) : self
        check Lib.pn_data_put_int(@raw, value), "pn_data_put_int"
        self
      end

      def put(value : UInt64) : self
        check Lib.pn_data_put_ulong(@raw, value), "pn_data_put_ulong"
        self
      end

      def put(value : Int64) : self
        check Lib.pn_data_put_long(@raw, value), "pn_data_put_long"
        self
      end

      def put(value : Float32) : self
        check Lib.pn_data_put_float(@raw, value), "pn_data_put_float"
        self
      end

      def put(value : Float64) : self
        check Lib.pn_data_put_double(@raw, value), "pn_data_put_double"
        self
      end

      def put(value : String) : self
        put_string(value)
      end

      def put_string(value : String) : self
        check Lib.pn_data_put_string(@raw, Proton.pn_bytes(value)), "pn_data_put_string"
        self
      end

      def put_symbol(value : String) : self
        check Lib.pn_data_put_symbol(@raw, Proton.pn_bytes(value)), "pn_data_put_symbol"
        self
      end

      def put_binary(value : Bytes) : self
        check Lib.pn_data_put_binary(@raw, Proton.pn_bytes(value)), "pn_data_put_binary"
        self
      end

      def put_timestamp(value : Time) : self
        check Lib.pn_data_put_timestamp(@raw, value.to_unix_ms), "pn_data_put_timestamp"
        self
      end

      def put_timestamp_ms(value : Int64) : self
        check Lib.pn_data_put_timestamp(@raw, value), "pn_data_put_timestamp"
        self
      end

      def put_char(value : ::Char) : self
        check Lib.pn_data_put_char(@raw, value.ord.to_u32), "pn_data_put_char"
        self
      end

      def put_list : self
        check Lib.pn_data_put_list(@raw), "pn_data_put_list"
        self
      end

      def put_map : self
        check Lib.pn_data_put_map(@raw), "pn_data_put_map"
        self
      end

      def put_array(type : Lib::Type, described = false) : self
        check Lib.pn_data_put_array(@raw, described, type), "pn_data_put_array"
        self
      end

      def put_described : self
        check Lib.pn_data_put_described(@raw), "pn_data_put_described"
        self
      end

      def list_size : Int32
        Lib.pn_data_get_list(@raw).to_i32
      end

      def map_size : Int32
        Lib.pn_data_get_map(@raw).to_i32
      end

      def array_size : Int32
        Lib.pn_data_get_array(@raw).to_i32
      end

      def described? : Bool
        Lib.pn_data_is_described(@raw)
      end

      def null? : Bool
        Lib.pn_data_is_null(@raw)
      end

      def bool : Bool
        Lib.pn_data_get_bool(@raw)
      end

      def ubyte : UInt8
        Lib.pn_data_get_ubyte(@raw)
      end

      def byte : Int8
        Lib.pn_data_get_byte(@raw)
      end

      def ushort : UInt16
        Lib.pn_data_get_ushort(@raw)
      end

      def short : Int16
        Lib.pn_data_get_short(@raw)
      end

      def uint : UInt32
        Lib.pn_data_get_uint(@raw)
      end

      def int : Int32
        Lib.pn_data_get_int(@raw)
      end

      def ulong : UInt64
        Lib.pn_data_get_ulong(@raw)
      end

      def long : Int64
        Lib.pn_data_get_long(@raw)
      end

      def timestamp_ms : Int64
        Lib.pn_data_get_timestamp(@raw)
      end

      def float : Float32
        Lib.pn_data_get_float(@raw)
      end

      def double : Float64
        Lib.pn_data_get_double(@raw)
      end

      def string : String
        Proton.bytes_to_string(Lib.pn_data_get_string(@raw))
      end

      def symbol : String
        Proton.bytes_to_string(Lib.pn_data_get_symbol(@raw))
      end

      def binary : Bytes
        Proton.bytes_to_slice(Lib.pn_data_get_binary(@raw))
      end

      def bytes : Bytes
        Proton.bytes_to_slice(Lib.pn_data_get_bytes(@raw))
      end

      def current : Scalar
        case type
        in Lib::Type::Null
          nil
        in Lib::Type::Bool
          bool
        in Lib::Type::Ubyte
          ubyte
        in Lib::Type::Byte
          byte
        in Lib::Type::Ushort
          ushort
        in Lib::Type::Short
          short
        in Lib::Type::Uint, Lib::Type::Char
          uint
        in Lib::Type::Int
          int
        in Lib::Type::Ulong
          ulong
        in Lib::Type::Long, Lib::Type::Timestamp
          long
        in Lib::Type::Float
          float
        in Lib::Type::Double
          double
        in Lib::Type::String
          string
        in Lib::Type::Symbol
          symbol
        in Lib::Type::Binary
          binary
        in Lib::Type::Decimal32, Lib::Type::Decimal64, Lib::Type::Decimal128,
           Lib::Type::Uuid, Lib::Type::Described, Lib::Type::Array,
           Lib::Type::List, Lib::Type::Map, Lib::Type::Invalid
          raise Error.new("Cannot convert current AMQP #{type_name} node to a scalar")
        end
      end

      def copy_from(other : Data) : self
        check Lib.pn_data_copy(@raw, other.raw), "pn_data_copy"
        self
      end

      def append(other : Data) : self
        check Lib.pn_data_append(@raw, other.raw), "pn_data_append"
        self
      end

      def encoded_size : Int64
        size = Lib.pn_data_encoded_size(@raw)
        check size, "pn_data_encoded_size"
        size
      end

      def encode : Bytes
        size = encoded_size
        return Bytes.empty if size == 0

        buffer = Bytes.new(size.to_i)
        written = Lib.pn_data_encode(@raw, buffer.to_unsafe, buffer.size)
        check written, "pn_data_encode"
        buffer[0, written.to_i].dup
      end

      def decode(bytes : Bytes) : Int64
        read = Lib.pn_data_decode(@raw, bytes.to_unsafe, bytes.size)
        check read, "pn_data_decode"
        read
      end

      def decode(string : String) : Int64
        decode(string.to_slice)
      end

      def format : String
        capacity = 256

        loop do
          buffer = Bytes.new(capacity)
          used = capacity.to_u64
          code = Lib.pn_data_format(@raw, buffer.to_unsafe, pointerof(used))

          return String.new(buffer[0, used.to_i]) if code == Lib::OK

          if code == Lib::OVERFLOW
            capacity *= 2
            next
          end

          check code, "pn_data_format"
        end
      end

      def to_s(io : IO) : Nil
        io << format
      end

      private def check(code : Int, context : String) : Nil
        Proton.check!(code, error, context)
      end
    end
  end
end
