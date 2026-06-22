module Qpid
  module Proton
    class Condition < Handle
      getter raw : Lib::Condition*

      def initialize
        @raw = Proton.check_pointer!(Lib.pn_condition, "pn_condition")
        @owned = true
        @owner = nil
      end

      protected def initialize(@raw : Lib::Condition*, @owned : Bool, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_condition")
      end

      def self.wrap(raw : Lib::Condition*, owner : Handle? = nil) : self
        new(raw, owned: false, owner: owner)
      end

      def finalize
        free
      end

      def free : Nil
        if @owned && !@raw.null?
          Lib.pn_condition_free(@raw)
          @raw = Pointer(Lib::Condition).null
        end
      end

      def set? : Bool
        Lib.pn_condition_is_set(@raw)
      end

      def clear : Nil
        Lib.pn_condition_clear(@raw)
      end

      def name : String?
        Proton.string_or_nil(Lib.pn_condition_get_name(@raw))
      end

      def name=(value : String?) : String?
        pointer = value ? value.to_unsafe : Pointer(UInt8).null
        Proton.check!(Lib.pn_condition_set_name(@raw, pointer), context: "pn_condition_set_name")
        value
      end

      def description : String?
        Proton.string_or_nil(Lib.pn_condition_get_description(@raw))
      end

      def description=(value : String?) : String?
        pointer = value ? value.to_unsafe : Pointer(UInt8).null
        Proton.check!(Lib.pn_condition_set_description(@raw, pointer), context: "pn_condition_set_description")
        value
      end

      def info : Data
        Data.wrap(Lib.pn_condition_info(@raw), self)
      end

      def redirect? : Bool
        Lib.pn_condition_is_redirect(@raw)
      end

      def redirect_host : String?
        Proton.string_or_nil(Lib.pn_condition_redirect_host(@raw))
      end

      def redirect_port : Int32
        Lib.pn_condition_redirect_port(@raw)
      end

      def copy_from(other : Condition) : self
        Proton.check!(Lib.pn_condition_copy(@raw, other.raw), context: "pn_condition_copy")
        self
      end

      def to_s(io : IO) : Nil
        if set?
          io << name
          if description
            io << ": " << description
          end
        else
          io << "(unset)"
        end
      end
    end
  end
end
