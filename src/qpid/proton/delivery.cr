module Qpid
  module Proton
    class Delivery < Handle
      getter raw : Lib::Delivery*

      protected def initialize(@raw : Lib::Delivery*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_delivery")
      end

      def self.wrap(raw : Lib::Delivery*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def tag : Bytes
        Proton.bytes_to_slice(Lib.pn_delivery_tag(@raw))
      end

      def link : Link
        Link.wrap(Lib.pn_delivery_link(@raw), self)
      end

      def local : Disposition
        Disposition.wrap(Lib.pn_delivery_local(@raw), self)
      end

      def remote : Disposition
        Disposition.wrap(Lib.pn_delivery_remote(@raw), self)
      end

      def local_state : UInt64
        Lib.pn_delivery_local_state(@raw)
      end

      def remote_state : UInt64
        Lib.pn_delivery_remote_state(@raw)
      end

      def settled? : Bool
        Lib.pn_delivery_settled(@raw)
      end

      def pending : UInt64
        Lib.pn_delivery_pending(@raw)
      end

      def partial? : Bool
        Lib.pn_delivery_partial(@raw)
      end

      def aborted? : Bool
        Lib.pn_delivery_aborted(@raw)
      end

      def writable? : Bool
        Lib.pn_delivery_writable(@raw)
      end

      def readable? : Bool
        Lib.pn_delivery_readable(@raw)
      end

      def updated? : Bool
        Lib.pn_delivery_updated(@raw)
      end

      def update(state : UInt64) : self
        Lib.pn_delivery_update(@raw, state)
        self
      end

      def accept : self
        update(Lib::ACCEPTED)
      end

      def reject : self
        update(Lib::REJECTED)
      end

      def release : self
        update(Lib::RELEASED)
      end

      def modify : self
        update(Lib::MODIFIED)
      end

      def clear : self
        Lib.pn_delivery_clear(@raw)
        self
      end

      def current? : Bool
        Lib.pn_delivery_current(@raw)
      end

      def abort : Nil
        Lib.pn_delivery_abort(@raw)
      end

      def settle : Nil
        Lib.pn_delivery_settle(@raw)
      end

      def buffered? : Bool
        Lib.pn_delivery_buffered(@raw)
      end
    end

    class Disposition < Handle
      getter raw : Lib::Disposition*

      protected def initialize(@raw : Lib::Disposition*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_disposition")
      end

      def self.wrap(raw : Lib::Disposition*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def type : UInt64
        Lib.pn_disposition_type(@raw)
      end

      def type_name : String
        Proton.string_or_nil(Lib.pn_disposition_type_name(type)) || type.to_s
      end

      def condition : Condition
        Condition.wrap(Lib.pn_disposition_condition(@raw), self)
      end

      def data : Data
        Data.wrap(Lib.pn_disposition_data(@raw), self)
      end

      def section_number : UInt32
        Lib.pn_disposition_get_section_number(@raw)
      end

      def section_number=(value : UInt32) : UInt32
        Lib.pn_disposition_set_section_number(@raw, value)
        value
      end

      def section_offset : UInt64
        Lib.pn_disposition_get_section_offset(@raw)
      end

      def section_offset=(value : UInt64) : UInt64
        Lib.pn_disposition_set_section_offset(@raw, value)
        value
      end

      def failed? : Bool
        Lib.pn_disposition_is_failed(@raw)
      end

      def failed=(value : Bool) : Bool
        Lib.pn_disposition_set_failed(@raw, value)
        value
      end

      def undeliverable? : Bool
        Lib.pn_disposition_is_undeliverable(@raw)
      end

      def undeliverable=(value : Bool) : Bool
        Lib.pn_disposition_set_undeliverable(@raw, value)
        value
      end

      def annotations : Data
        Data.wrap(Lib.pn_disposition_annotations(@raw), self)
      end
    end
  end
end
