module Qpid
  module Proton
    class Error < Exception
      getter code : Int32?
      getter name : String?
      getter detail : String?

      def initialize(message : String, @code : Int32? = nil, @name : String? = nil, @detail : String? = nil)
        super(message)
      end

      def self.from_code(code : Int, detail : Lib::Error* = Pointer(Lib::Error).null, context = "Proton") : self
        code = code.to_i32
        name = code_name(code)
        text = detail.null? ? nil : Proton.string_or_nil(Lib.pn_error_text(detail))

        message = String.build do |io|
          io << context << " failed"
          io << " (#{name})" if name
          io << ": " << text if text && !text.empty?
        end

        new(message, code, name, text)
      end

      def self.code_name(code : Int) : String?
        Proton.string_or_nil(Lib.pn_code(code.to_i32))
      end
    end
  end
end
