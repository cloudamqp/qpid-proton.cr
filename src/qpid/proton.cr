require "./proton/lib"
require "./proton/handle"
require "./proton/error"
require "./proton/data"
require "./proton/condition"
require "./proton/message"
require "./proton/connection"
require "./proton/session"
require "./proton/terminus"
require "./proton/link"
require "./proton/delivery"
require "./proton/transport"
require "./proton/event"
require "./proton/connection_driver"
require "./proton/client"

module Qpid
  module Proton
    VERSION = "0.1.0"

    LIB_VERSION_MAJOR =  0
    LIB_VERSION_MINOR = 40
    LIB_VERSION_POINT =  0
    LIB_VERSION       = "#{LIB_VERSION_MAJOR}.#{LIB_VERSION_MINOR}.#{LIB_VERSION_POINT}"

    def self.string_or_nil(pointer : UInt8*) : String?
      pointer.null? ? nil : String.new(pointer)
    end

    def self.bytes_to_slice(bytes : Lib::Bytes) : Bytes
      return Bytes.empty if bytes.start.null? || bytes.size == 0

      Slice.new(bytes.start, bytes.size.to_i).dup
    end

    def self.bytes_to_string(bytes : Lib::Bytes) : String
      return "" if bytes.start.null? || bytes.size == 0

      String.new(bytes.start, bytes.size.to_i)
    end

    def self.pn_bytes(value : String) : Lib::Bytes
      Lib::Bytes.new(size: value.bytesize, start: value.to_unsafe)
    end

    def self.pn_bytes(value : Bytes) : Lib::Bytes
      Lib::Bytes.new(size: value.size, start: value.to_unsafe)
    end

    def self.check!(code : Int, detail : Lib::Error* = Pointer(Lib::Error).null, context = "Proton") : Nil
      return if code >= Lib::OK

      raise Error.from_code(code, detail, context)
    end

    def self.check_pointer!(pointer, context = "Proton")
      raise Error.new("#{context} returned NULL") if pointer.null?

      pointer
    end
  end
end
