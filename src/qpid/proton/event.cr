module Qpid
  module Proton
    class Collector < Handle
      getter raw : Lib::Collector*

      def initialize
        @raw = Proton.check_pointer!(Lib.pn_collector, "pn_collector")
        @owned = true
        @owner = nil
      end

      protected def initialize(@raw : Lib::Collector*, @owned : Bool, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_collector")
      end

      def self.wrap(raw : Lib::Collector*, owner : Handle? = nil) : self
        new(raw, owned: false, owner: owner)
      end

      def finalize
        free
      end

      def free : Nil
        if @owned && !@raw.null?
          Lib.pn_collector_free(@raw)
          @raw = Pointer(Lib::Collector).null
        end
      end

      def release : self
        Lib.pn_collector_release(@raw)
        self
      end

      def drain : self
        Lib.pn_collector_drain(@raw)
        self
      end

      def peek : Event?
        pointer = Lib.pn_collector_peek(@raw)
        pointer.null? ? nil : Event.wrap(pointer, self)
      end

      def pop : Bool
        Lib.pn_collector_pop(@raw)
      end

      def next : Event?
        pointer = Lib.pn_collector_next(@raw)
        pointer.null? ? nil : Event.wrap(pointer, self)
      end

      def previous : Event?
        pointer = Lib.pn_collector_prev(@raw)
        pointer.null? ? nil : Event.wrap(pointer, self)
      end

      def more? : Bool
        Lib.pn_collector_more(@raw)
      end
    end

    class Event < Handle
      getter raw : Lib::Event*

      protected def initialize(@raw : Lib::Event*, @owner : Handle? = nil)
        Proton.check_pointer!(@raw, "pn_event")
      end

      def self.wrap(raw : Lib::Event*, owner : Handle? = nil) : self
        new(raw, owner)
      end

      def type : Lib::EventType
        Lib.pn_event_type(@raw)
      end

      def type_name : String
        Proton.string_or_nil(Lib.pn_event_type_name(type)) || type.to_s
      end

      def connection : Connection?
        pointer = Lib.pn_event_connection(@raw)
        pointer.null? ? nil : Connection.wrap(pointer, self)
      end

      def session : Session?
        pointer = Lib.pn_event_session(@raw)
        pointer.null? ? nil : Session.wrap(pointer, self)
      end

      def link : Link?
        pointer = Lib.pn_event_link(@raw)
        pointer.null? ? nil : Link.wrap(pointer, self)
      end

      def delivery : Delivery?
        pointer = Lib.pn_event_delivery(@raw)
        pointer.null? ? nil : Delivery.wrap(pointer, self)
      end

      def transport : Transport?
        pointer = Lib.pn_event_transport(@raw)
        pointer.null? ? nil : Transport.wrap(pointer, self)
      end

      def condition : Condition?
        pointer = Lib.pn_event_condition(@raw)
        pointer.null? ? nil : Condition.wrap(pointer, self)
      end

      {% if flag?(:qpid_proton_system) %}
        def listener : Listener?
          pointer = Lib.pn_event_listener(@raw)
          pointer.null? ? nil : Listener.wrap(pointer, self)
        end
      {% end %}
    end

    {% if flag?(:qpid_proton_system) %}
      class Listener < Handle
        getter raw : Lib::Listener*

        def initialize
          @raw = Proton.check_pointer!(Lib.pn_listener, "pn_listener")
          @owned = true
          @owner = nil
        end

        protected def initialize(@raw : Lib::Listener*, @owned : Bool, @owner : Handle? = nil)
          Proton.check_pointer!(@raw, "pn_listener")
        end

        def self.wrap(raw : Lib::Listener*, owner : Handle? = nil) : self
          new(raw, owned: false, owner: owner)
        end

        def finalize
          free
        end

        def free : Nil
          if @owned && !@raw.null?
            Lib.pn_listener_free(@raw)
            @raw = Pointer(Lib::Listener).null
          end
        end

        def accept(connection : Connection? = nil, transport : Transport? = nil) : self
          Lib.pn_listener_accept2(
            @raw,
            connection ? connection.raw : Pointer(Lib::Connection).null,
            transport ? transport.raw : Pointer(Lib::Transport).null
          )
          self
        end

        def condition : Condition
          Condition.wrap(Lib.pn_listener_condition(@raw), self)
        end

        def close : self
          Lib.pn_listener_close(@raw)
          self
        end
      end
    {% end %}
  end
end
