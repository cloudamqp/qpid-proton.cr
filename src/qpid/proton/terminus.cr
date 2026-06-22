module Qpid
  module Proton
    class Terminus < Handle
      getter raw : Lib::Terminus*

      protected def initialize(@raw : Lib::Terminus*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_terminus")
      end

      def self.wrap(raw : Lib::Terminus*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def type : Lib::TerminusType
        Lib.pn_terminus_get_type(@raw)
      end

      def type=(value : Lib::TerminusType) : Lib::TerminusType
        Proton.check!(Lib.pn_terminus_set_type(@raw, value), context: "pn_terminus_set_type")
        value
      end

      def address : String?
        Proton.string_or_nil(Lib.pn_terminus_get_address(@raw))
      end

      def address=(value : String?) : String?
        pointer = value ? value.to_unsafe : Pointer(UInt8).null
        Proton.check!(Lib.pn_terminus_set_address(@raw, pointer), context: "pn_terminus_set_address")
        value
      end

      def distribution_mode : Lib::DistributionMode
        Lib.pn_terminus_get_distribution_mode(@raw)
      end

      def distribution_mode=(value : Lib::DistributionMode) : Lib::DistributionMode
        Proton.check!(Lib.pn_terminus_set_distribution_mode(@raw, value), context: "pn_terminus_set_distribution_mode")
        value
      end

      def durability : Lib::Durability
        Lib.pn_terminus_get_durability(@raw)
      end

      def durability=(value : Lib::Durability) : Lib::Durability
        Proton.check!(Lib.pn_terminus_set_durability(@raw, value), context: "pn_terminus_set_durability")
        value
      end

      def expiry_policy : Lib::ExpiryPolicy
        Lib.pn_terminus_get_expiry_policy(@raw)
      end

      def expiry_policy=(value : Lib::ExpiryPolicy) : Lib::ExpiryPolicy
        Proton.check!(Lib.pn_terminus_set_expiry_policy(@raw, value), context: "pn_terminus_set_expiry_policy")
        value
      end

      def expiry_policy? : Bool
        Lib.pn_terminus_has_expiry_policy(@raw)
      end

      def timeout : UInt32
        Lib.pn_terminus_get_timeout(@raw)
      end

      def timeout=(value : UInt32) : UInt32
        Proton.check!(Lib.pn_terminus_set_timeout(@raw, value), context: "pn_terminus_set_timeout")
        value
      end

      def dynamic? : Bool
        Lib.pn_terminus_is_dynamic(@raw)
      end

      def dynamic=(value : Bool) : Bool
        Proton.check!(Lib.pn_terminus_set_dynamic(@raw, value), context: "pn_terminus_set_dynamic")
        value
      end

      def properties : Data
        Data.wrap(Lib.pn_terminus_properties(@raw), self)
      end

      def capabilities : Data
        Data.wrap(Lib.pn_terminus_capabilities(@raw), self)
      end

      def outcomes : Data
        Data.wrap(Lib.pn_terminus_outcomes(@raw), self)
      end

      def filter : Data
        Data.wrap(Lib.pn_terminus_filter(@raw), self)
      end

      def copy_from(other : Terminus) : self
        Proton.check!(Lib.pn_terminus_copy(@raw, other.raw), context: "pn_terminus_copy")
        self
      end
    end
  end
end
