module Qpid
  module Proton
    class Link < Handle
      include EndpointState

      getter raw : Lib::Link*

      protected def initialize(@raw : Lib::Link*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_link")
      end

      def self.wrap(raw : Lib::Link*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def name : String
        Proton.string_or_nil(Lib.pn_link_name(@raw)) || ""
      end

      def sender? : Bool
        Lib.pn_link_is_sender(@raw)
      end

      def receiver? : Bool
        Lib.pn_link_is_receiver(@raw)
      end

      def state : Int32
        Lib.pn_link_state(@raw)
      end

      def error : Lib::Error*
        Lib.pn_link_error(@raw)
      end

      def open : self
        Lib.pn_link_open(@raw)
        self
      end

      def close : self
        Lib.pn_link_close(@raw)
        self
      end

      def detach : self
        Lib.pn_link_detach(@raw)
        self
      end

      def condition : Condition
        Condition.wrap(Lib.pn_link_condition(@raw), self)
      end

      def remote_condition : Condition
        Condition.wrap(Lib.pn_link_remote_condition(@raw), self)
      end

      def session : Session
        Session.wrap(Lib.pn_link_session(@raw), self)
      end

      def source : Terminus
        Terminus.wrap(Lib.pn_link_source(@raw), self)
      end

      def target : Terminus
        Terminus.wrap(Lib.pn_link_target(@raw), self)
      end

      def remote_source : Terminus
        Terminus.wrap(Lib.pn_link_remote_source(@raw), self)
      end

      def remote_target : Terminus
        Terminus.wrap(Lib.pn_link_remote_target(@raw), self)
      end

      def current_delivery : Delivery?
        pointer = Lib.pn_link_current(@raw)
        pointer.null? ? nil : Delivery.wrap(pointer, self)
      end

      def advance : Bool
        Lib.pn_link_advance(@raw)
      end

      def credit : Int32
        Lib.pn_link_credit(@raw)
      end

      def queued : Int32
        Lib.pn_link_queued(@raw)
      end

      def remote_credit : Int32
        Lib.pn_link_remote_credit(@raw)
      end

      def drain? : Bool
        Lib.pn_link_get_drain(@raw)
      end

      def drained : Int32
        Lib.pn_link_drained(@raw)
      end

      def available : Int32
        Lib.pn_link_available(@raw)
      end

      def sender_settle_mode : Lib::SenderSettleMode
        Lib.pn_link_snd_settle_mode(@raw)
      end

      def sender_settle_mode=(value : Lib::SenderSettleMode) : Lib::SenderSettleMode
        Lib.pn_link_set_snd_settle_mode(@raw, value)
        value
      end

      def receiver_settle_mode : Lib::ReceiverSettleMode
        Lib.pn_link_rcv_settle_mode(@raw)
      end

      def receiver_settle_mode=(value : Lib::ReceiverSettleMode) : Lib::ReceiverSettleMode
        Lib.pn_link_set_rcv_settle_mode(@raw, value)
        value
      end

      def unsettled : Int32
        Lib.pn_link_unsettled(@raw)
      end

      def delivery(tag : String) : Delivery
        delivery(tag.to_slice)
      end

      def delivery(tag : Bytes) : Delivery
        ctag = Lib.pn_dtag(tag.to_unsafe, tag.size)
        Delivery.wrap(Proton.check_pointer!(Lib.pn_delivery(@raw, ctag), "pn_delivery"), self)
      end

      def offered(credit : Int32) : self
        Lib.pn_link_offered(@raw, credit)
        self
      end

      def flow(credit : Int32) : self
        Lib.pn_link_flow(@raw, credit)
        self
      end

      def drain(credit : Int32) : self
        Lib.pn_link_drain(@raw, credit)
        self
      end

      def drain=(value : Bool) : Bool
        Lib.pn_link_set_drain(@raw, value)
        value
      end

      def draining? : Bool
        Lib.pn_link_draining(@raw)
      end

      def send(bytes : Bytes) : Int64
        sent = Lib.pn_link_send(@raw, bytes.to_unsafe, bytes.size)
        Proton.check!(sent, error, "pn_link_send")
        sent
      end

      def send(string : String) : Int64
        send(string.to_slice)
      end

      def receive(max = 4096) : Bytes
        buffer = Bytes.new(max)
        received = Lib.pn_link_recv(@raw, buffer.to_unsafe, buffer.size)
        return Bytes.empty if received == Lib::EOS

        Proton.check!(received, error, "pn_link_recv")
        buffer[0, received.to_i].dup
      end

      def max_message_size : UInt64
        Lib.pn_link_max_message_size(@raw)
      end

      def max_message_size=(value : UInt64) : UInt64
        Lib.pn_link_set_max_message_size(@raw, value)
        value
      end

      def remote_max_message_size : UInt64
        Lib.pn_link_remote_max_message_size(@raw)
      end

      def properties : Data
        Data.wrap(Lib.pn_link_properties(@raw), self)
      end

      def remote_properties : Data
        Data.wrap(Lib.pn_link_remote_properties(@raw), self)
      end
    end
  end
end
