module Qpid
  module Proton
    {% if flag?(:qpid_proton_system) %}
      @[Link("qpid-proton")]
    {% else %}
      @[Link(ldflags: "#{__DIR__}/../../../ext/qpid-proton/build/c/libqpid-proton-core-static.a")]
    {% end %}
    lib Lib
      alias SizeT = LibC::SizeT
      alias SSizeT = LibC::SSizeT
      alias Sequence = UInt32
      alias FrameCount = UInt32
      alias Millis = UInt32
      alias Seconds = UInt32
      alias Timestamp = Int64
      alias Char32 = UInt32
      alias Decimal32 = UInt32
      alias Decimal64 = UInt64
      alias State = Int32
      alias Trace = Int32
      alias Handle = Void*

      OK            =   0
      EOS           =  -1
      ERR           =  -2
      OVERFLOW      =  -3
      UNDERFLOW     =  -4
      STATE_ERR     =  -5
      ARG_ERR       =  -6
      TIMEOUT       =  -7
      INTR          =  -8
      INPROGRESS    =  -9
      OUT_OF_MEMORY = -10
      ABORTED       = -11

      DEFAULT_PRIORITY = 4_u8
      MILLIS_MAX       = UInt32::MAX
      MAX_ADDR         = 1060

      LOCAL_UNINIT  =  1
      LOCAL_ACTIVE  =  2
      LOCAL_CLOSED  =  4
      REMOTE_UNINIT =  8
      REMOTE_ACTIVE = 16
      REMOTE_CLOSED = 32
      LOCAL_MASK    = LOCAL_UNINIT | LOCAL_ACTIVE | LOCAL_CLOSED
      REMOTE_MASK   = REMOTE_UNINIT | REMOTE_ACTIVE | REMOTE_CLOSED

      TRACE_OFF = 0
      TRACE_RAW = 1
      TRACE_FRM = 2
      TRACE_DRV = 4
      TRACE_EVT = 8

      RECEIVED = 0x0000000000000023_u64
      ACCEPTED = 0x0000000000000024_u64
      REJECTED = 0x0000000000000025_u64
      RELEASED = 0x0000000000000026_u64
      MODIFIED = 0x0000000000000027_u64

      TLS_OK                 =  0
      TLS_INIT_ERR           = -1
      TLS_PROTOCOL_ERR       = -2
      TLS_AUTHENTICATION_ERR = -3
      TLS_STATE_ERR          = -4

      type Error = Void
      type Data = Void
      type Message = Void
      type Connection = Void
      type Session = Void
      type Link = Void
      type Delivery = Void
      type Collector = Void
      type Event = Void
      type Class = Void
      type Record = Void
      type Condition = Void
      type Terminus = Void
      type Disposition = Void
      type Transport = Void
      type Logger = Void
      type Sasl = Void
      type Proactor = Void
      type Listener = Void
      type EventBatch = Void
      type RawConnection = Void
      type TlsConfig = Void
      type Tls = Void

      struct Decimal128
        bytes : StaticArray(UInt8, 16)
      end

      struct Uuid
        bytes : StaticArray(UInt8, 16)
      end

      struct Bytes
        size : SizeT
        start : UInt8*
      end

      struct RWBytes
        size : SizeT
        start : UInt8*
      end

      enum Type
        Null       =  1
        Bool       =  2
        Ubyte      =  3
        Byte       =  4
        Ushort     =  5
        Short      =  6
        Uint       =  7
        Int        =  8
        Char       =  9
        Ulong      = 10
        Long       = 11
        Timestamp  = 12
        Float      = 13
        Double     = 14
        Decimal32  = 15
        Decimal64  = 16
        Decimal128 = 17
        Uuid       = 18
        Binary     = 19
        String     = 20
        Symbol     = 21
        Described  = 22
        Array      = 23
        List       = 24
        Map        = 25
        Invalid    = -1
      end

      union AtomValue
        as_bool : Bool
        as_ubyte : UInt8
        as_byte : Int8
        as_ushort : UInt16
        as_short : Int16
        as_uint : UInt32
        as_int : Int32
        as_char : Char32
        as_ulong : UInt64
        as_long : Int64
        as_timestamp : Timestamp
        as_float : Float32
        as_double : Float64
        as_decimal32 : Decimal32
        as_decimal64 : Decimal64
        as_decimal128 : Decimal128
        as_uuid : Uuid
        as_bytes : Bytes
      end

      struct Atom
        type : Type
        u : AtomValue
      end

      alias MsgId = Atom
      alias DeliveryTag = Bytes

      enum SenderSettleMode
        Unsettled = 0
        Settled   = 1
        Mixed     = 2
      end

      enum ReceiverSettleMode
        First  = 0
        Second = 1
      end

      enum TerminusType
        Unspecified = 0
        Source      = 1
        Target      = 2
        Coordinator = 3
      end

      enum Durability
        Nondurable    = 0
        Configuration = 1
        Deliveries    = 2
      end

      enum ExpiryPolicy
        WithLink       = 0
        WithSession    = 1
        WithConnection = 2
        Never          = 3
      end

      enum DistributionMode
        Unspecified = 0
        Copy        = 1
        Move        = 2
      end

      enum EventType
        None                          = 0
        ReactorInit
        ReactorQuiesced
        ReactorFinal
        TimerTask
        ConnectionInit
        ConnectionBound
        ConnectionUnbound
        ConnectionLocalOpen
        ConnectionRemoteOpen
        ConnectionLocalClose
        ConnectionRemoteClose
        ConnectionFinal
        SessionInit
        SessionLocalOpen
        SessionRemoteOpen
        SessionLocalClose
        SessionRemoteClose
        SessionFinal
        LinkInit
        LinkLocalOpen
        LinkRemoteOpen
        LinkLocalClose
        LinkRemoteClose
        LinkLocalDetach
        LinkRemoteDetach
        LinkFlow
        LinkFinal
        Delivery
        Transport
        TransportAuthenticated
        TransportError
        TransportHeadClosed
        TransportTailClosed
        TransportClosed
        SelectableInit
        SelectableUpdated
        SelectableReadable
        SelectableWritable
        SelectableError
        SelectableExpired
        SelectableFinal
        ConnectionWake
        ListenerAccept
        ListenerClose
        ProactorInterrupt
        ProactorTimeout
        ProactorInactive
        ListenerOpen
        RawConnectionConnected
        RawConnectionClosedRead
        RawConnectionClosedWrite
        RawConnectionDisconnected
        RawConnectionNeedReadBuffers
        RawConnectionNeedWriteBuffers
        RawConnectionRead
        RawConnectionWritten
        RawConnectionWake
        RawConnectionDrainBuffers
      end

      enum SaslOutcome
        None = -1
        Ok   =  0
        Auth =  1
        Sys  =  2
        Perm =  3
        Temp =  4
      end

      enum TlsMode
        Client = 1
        Server = 2
      end

      enum TlsVerifyMode
        Null      = 0
        Peer      = 1
        Anonymous = 2
        PeerName  = 3
      end

      struct ConnectionDriver
        connection : Connection*
        transport : Transport*
        collector : Collector*
      end

      alias Tracer = Transport*, UInt8* ->

      fun pn_code(code : Int32) : UInt8*

      fun pn_error : Error*
      fun pn_error_free(error : Error*)
      fun pn_error_clear(error : Error*)
      fun pn_error_set(error : Error*, code : Int32, text : UInt8*) : Int32
      fun pn_error_code(error : Error*) : Int32
      fun pn_error_text(error : Error*) : UInt8*
      fun pn_error_copy(error : Error*, src : Error*) : Int32

      fun pn_type_name(type : Type) : UInt8*

      fun pn_data(capacity : SizeT) : Data*
      fun pn_data_free(data : Data*)
      fun pn_data_errno(data : Data*) : Int32
      fun pn_data_error(data : Data*) : Error*
      fun pn_data_clear(data : Data*)
      fun pn_data_size(data : Data*) : SizeT
      fun pn_data_rewind(data : Data*)
      fun pn_data_next(data : Data*) : Bool
      fun pn_data_prev(data : Data*) : Bool
      fun pn_data_enter(data : Data*) : Bool
      fun pn_data_exit(data : Data*) : Bool
      fun pn_data_type(data : Data*) : Type
      fun pn_data_print(data : Data*) : Int32
      fun pn_data_format(data : Data*, bytes : UInt8*, size : SizeT*) : Int32
      fun pn_data_encode(data : Data*, bytes : UInt8*, size : SizeT) : SSizeT
      fun pn_data_encoded_size(data : Data*) : SSizeT
      fun pn_data_decode(data : Data*, bytes : UInt8*, size : SizeT) : SSizeT
      fun pn_data_put_list(data : Data*) : Int32
      fun pn_data_put_map(data : Data*) : Int32
      fun pn_data_put_array(data : Data*, described : Bool, type : Type) : Int32
      fun pn_data_put_described(data : Data*) : Int32
      fun pn_data_put_null(data : Data*) : Int32
      fun pn_data_put_bool(data : Data*, value : Bool) : Int32
      fun pn_data_put_ubyte(data : Data*, value : UInt8) : Int32
      fun pn_data_put_byte(data : Data*, value : Int8) : Int32
      fun pn_data_put_ushort(data : Data*, value : UInt16) : Int32
      fun pn_data_put_short(data : Data*, value : Int16) : Int32
      fun pn_data_put_uint(data : Data*, value : UInt32) : Int32
      fun pn_data_put_int(data : Data*, value : Int32) : Int32
      fun pn_data_put_char(data : Data*, value : Char32) : Int32
      fun pn_data_put_ulong(data : Data*, value : UInt64) : Int32
      fun pn_data_put_long(data : Data*, value : Int64) : Int32
      fun pn_data_put_timestamp(data : Data*, value : Timestamp) : Int32
      fun pn_data_put_float(data : Data*, value : Float32) : Int32
      fun pn_data_put_double(data : Data*, value : Float64) : Int32
      fun pn_data_put_decimal32(data : Data*, value : Decimal32) : Int32
      fun pn_data_put_decimal64(data : Data*, value : Decimal64) : Int32
      fun pn_data_put_decimal128(data : Data*, value : Decimal128) : Int32
      fun pn_data_put_uuid(data : Data*, value : Uuid) : Int32
      fun pn_data_put_binary(data : Data*, bytes : Bytes) : Int32
      fun pn_data_put_string(data : Data*, bytes : Bytes) : Int32
      fun pn_data_put_symbol(data : Data*, bytes : Bytes) : Int32
      fun pn_data_put_atom(data : Data*, atom : Atom) : Int32
      fun pn_data_get_list(data : Data*) : SizeT
      fun pn_data_get_map(data : Data*) : SizeT
      fun pn_data_get_array(data : Data*) : SizeT
      fun pn_data_is_array_described(data : Data*) : Bool
      fun pn_data_get_array_type(data : Data*) : Type
      fun pn_data_is_described(data : Data*) : Bool
      fun pn_data_is_null(data : Data*) : Bool
      fun pn_data_get_bool(data : Data*) : Bool
      fun pn_data_get_ubyte(data : Data*) : UInt8
      fun pn_data_get_byte(data : Data*) : Int8
      fun pn_data_get_ushort(data : Data*) : UInt16
      fun pn_data_get_short(data : Data*) : Int16
      fun pn_data_get_uint(data : Data*) : UInt32
      fun pn_data_get_int(data : Data*) : Int32
      fun pn_data_get_char(data : Data*) : Char32
      fun pn_data_get_ulong(data : Data*) : UInt64
      fun pn_data_get_long(data : Data*) : Int64
      fun pn_data_get_timestamp(data : Data*) : Timestamp
      fun pn_data_get_float(data : Data*) : Float32
      fun pn_data_get_double(data : Data*) : Float64
      fun pn_data_get_decimal32(data : Data*) : Decimal32
      fun pn_data_get_decimal64(data : Data*) : Decimal64
      fun pn_data_get_decimal128(data : Data*) : Decimal128
      fun pn_data_get_uuid(data : Data*) : Uuid
      fun pn_data_get_binary(data : Data*) : Bytes
      fun pn_data_get_string(data : Data*) : Bytes
      fun pn_data_get_symbol(data : Data*) : Bytes
      fun pn_data_get_bytes(data : Data*) : Bytes
      fun pn_data_get_atom(data : Data*) : Atom
      fun pn_data_copy(data : Data*, src : Data*) : Int32
      fun pn_data_append(data : Data*, src : Data*) : Int32
      fun pn_data_appendn(data : Data*, src : Data*, limit : Int32) : Int32
      fun pn_data_narrow(data : Data*)
      fun pn_data_widen(data : Data*)
      fun pn_data_point(data : Data*) : Handle
      fun pn_data_restore(data : Data*, point : Handle) : Bool
      fun pn_data_dump(data : Data*)

      fun pn_condition : Condition*
      fun pn_condition_free(condition : Condition*)
      fun pn_condition_is_set(condition : Condition*) : Bool
      fun pn_condition_clear(condition : Condition*)
      fun pn_condition_get_name(condition : Condition*) : UInt8*
      fun pn_condition_set_name(condition : Condition*, name : UInt8*) : Int32
      fun pn_condition_get_description(condition : Condition*) : UInt8*
      fun pn_condition_set_description(condition : Condition*, description : UInt8*) : Int32
      fun pn_condition_info(condition : Condition*) : Data*
      fun pn_condition_is_redirect(condition : Condition*) : Bool
      fun pn_condition_redirect_host(condition : Condition*) : UInt8*
      fun pn_condition_redirect_port(condition : Condition*) : Int32
      fun pn_condition_copy(dest : Condition*, src : Condition*) : Int32

      fun pn_message : Message*
      fun pn_message_free(msg : Message*)
      fun pn_message_clear(msg : Message*)
      fun pn_message_errno(msg : Message*) : Int32
      fun pn_message_error(msg : Message*) : Error*
      fun pn_message_is_inferred(msg : Message*) : Bool
      fun pn_message_set_inferred(msg : Message*, inferred : Bool) : Int32
      fun pn_message_is_durable(msg : Message*) : Bool
      fun pn_message_set_durable(msg : Message*, durable : Bool) : Int32
      fun pn_message_get_priority(msg : Message*) : UInt8
      fun pn_message_set_priority(msg : Message*, priority : UInt8) : Int32
      fun pn_message_get_ttl(msg : Message*) : Millis
      fun pn_message_set_ttl(msg : Message*, ttl : Millis) : Int32
      fun pn_message_is_first_acquirer(msg : Message*) : Bool
      fun pn_message_set_first_acquirer(msg : Message*, first : Bool) : Int32
      fun pn_message_get_delivery_count(msg : Message*) : UInt32
      fun pn_message_set_delivery_count(msg : Message*, count : UInt32) : Int32
      fun pn_message_id(msg : Message*) : Data*
      fun pn_message_get_id(msg : Message*) : MsgId
      fun pn_message_set_id(msg : Message*, id : MsgId) : Int32
      fun pn_message_get_user_id(msg : Message*) : Bytes
      fun pn_message_set_user_id(msg : Message*, user_id : Bytes) : Int32
      fun pn_message_get_address(msg : Message*) : UInt8*
      fun pn_message_set_address(msg : Message*, address : UInt8*) : Int32
      fun pn_message_get_subject(msg : Message*) : UInt8*
      fun pn_message_set_subject(msg : Message*, subject : UInt8*) : Int32
      fun pn_message_get_reply_to(msg : Message*) : UInt8*
      fun pn_message_set_reply_to(msg : Message*, reply_to : UInt8*) : Int32
      fun pn_message_correlation_id(msg : Message*) : Data*
      fun pn_message_get_correlation_id(msg : Message*) : MsgId
      fun pn_message_set_correlation_id(msg : Message*, id : MsgId) : Int32
      fun pn_message_get_content_type(msg : Message*) : UInt8*
      fun pn_message_set_content_type(msg : Message*, type : UInt8*) : Int32
      fun pn_message_get_content_encoding(msg : Message*) : UInt8*
      fun pn_message_set_content_encoding(msg : Message*, encoding : UInt8*) : Int32
      fun pn_message_get_expiry_time(msg : Message*) : Timestamp
      fun pn_message_set_expiry_time(msg : Message*, time : Timestamp) : Int32
      fun pn_message_get_creation_time(msg : Message*) : Timestamp
      fun pn_message_set_creation_time(msg : Message*, time : Timestamp) : Int32
      fun pn_message_get_group_id(msg : Message*) : UInt8*
      fun pn_message_set_group_id(msg : Message*, group_id : UInt8*) : Int32
      fun pn_message_get_group_sequence(msg : Message*) : Sequence
      fun pn_message_set_group_sequence(msg : Message*, n : Sequence) : Int32
      fun pn_message_get_reply_to_group_id(msg : Message*) : UInt8*
      fun pn_message_set_reply_to_group_id(msg : Message*, reply_to_group_id : UInt8*) : Int32
      fun pn_message_instructions(msg : Message*) : Data*
      fun pn_message_annotations(msg : Message*) : Data*
      fun pn_message_properties(msg : Message*) : Data*
      fun pn_message_body(msg : Message*) : Data*
      fun pn_message_decode(msg : Message*, bytes : UInt8*, size : SizeT) : Int32
      fun pn_message_encode(msg : Message*, bytes : UInt8*, size : SizeT*) : Int32
      fun pn_message_encode2(msg : Message*, buf : RWBytes*) : SSizeT
      fun pn_message_send(msg : Message*, sender : Link*, buf : RWBytes*) : SSizeT
      fun pn_message_data(msg : Message*, data : Data*) : Int32

      fun pn_connection : Connection*
      fun pn_connection_free(connection : Connection*)
      fun pn_connection_release(connection : Connection*)
      fun pn_connection_error(connection : Connection*) : Error*
      fun pn_connection_collect(connection : Connection*, collector : Collector*)
      fun pn_connection_collector(connection : Connection*) : Collector*
      fun pn_connection_get_context(connection : Connection*) : Void*
      fun pn_connection_set_context(connection : Connection*, context : Void*)
      fun pn_connection_attachments(connection : Connection*) : Record*
      fun pn_connection_state(connection : Connection*) : State
      fun pn_connection_open(connection : Connection*)
      fun pn_connection_close(connection : Connection*)
      fun pn_connection_reset(connection : Connection*)
      fun pn_connection_condition(connection : Connection*) : Condition*
      fun pn_connection_remote_condition(connection : Connection*) : Condition*
      fun pn_connection_get_container(connection : Connection*) : UInt8*
      fun pn_connection_set_container(connection : Connection*, container : UInt8*)
      fun pn_connection_set_user(connection : Connection*, user : UInt8*)
      fun pn_connection_set_password(connection : Connection*, password : UInt8*)
      fun pn_connection_set_authorization(connection : Connection*, authzid : UInt8*)
      fun pn_connection_get_user(connection : Connection*) : UInt8*
      fun pn_connection_get_authorization(connection : Connection*) : UInt8*
      fun pn_connection_get_hostname(connection : Connection*) : UInt8*
      fun pn_connection_set_hostname(connection : Connection*, hostname : UInt8*)
      fun pn_connection_remote_container(connection : Connection*) : UInt8*
      fun pn_connection_remote_hostname(connection : Connection*) : UInt8*
      fun pn_connection_offered_capabilities(connection : Connection*) : Data*
      fun pn_connection_desired_capabilities(connection : Connection*) : Data*
      fun pn_connection_properties(connection : Connection*) : Data*
      fun pn_connection_remote_offered_capabilities(connection : Connection*) : Data*
      fun pn_connection_remote_desired_capabilities(connection : Connection*) : Data*
      fun pn_connection_remote_properties(connection : Connection*) : Data*
      fun pn_connection_transport(connection : Connection*) : Transport*
      fun pn_connection_wake(connection : Connection*)
      fun pn_connection_write_flush(connection : Connection*)

      fun pn_session(connection : Connection*) : Session*
      fun pn_session_free(session : Session*)
      fun pn_session_get_context(session : Session*) : Void*
      fun pn_session_set_context(session : Session*, context : Void*)
      fun pn_session_attachments(session : Session*) : Record*
      fun pn_session_state(session : Session*) : State
      fun pn_session_error(session : Session*) : Error*
      fun pn_session_condition(session : Session*) : Condition*
      fun pn_session_remote_condition(session : Session*) : Condition*
      fun pn_session_connection(session : Session*) : Connection*
      fun pn_session_open(session : Session*)
      fun pn_session_close(session : Session*)
      fun pn_session_get_incoming_capacity(session : Session*) : SizeT
      fun pn_session_set_incoming_capacity(session : Session*, capacity : SizeT)
      fun pn_session_incoming_window(session : Session*) : FrameCount
      fun pn_session_incoming_window_lwm(session : Session*) : FrameCount
      fun pn_session_set_incoming_window_and_lwm(session : Session*, window : FrameCount, lwm : FrameCount) : Int32
      fun pn_session_remote_incoming_window(session : Session*) : FrameCount
      fun pn_session_get_outgoing_window(session : Session*) : SizeT
      fun pn_session_set_outgoing_window(session : Session*, window : SizeT)
      fun pn_session_outgoing_bytes(session : Session*) : SizeT
      fun pn_session_incoming_bytes(session : Session*) : SizeT
      fun pn_session_head(connection : Connection*, state : State) : Session*
      fun pn_session_next(session : Session*, state : State) : Session*

      fun pn_sender(session : Session*, name : UInt8*) : Link*
      fun pn_receiver(session : Session*, name : UInt8*) : Link*
      fun pn_link_free(link : Link*)
      fun pn_link_get_context(link : Link*) : Void*
      fun pn_link_set_context(link : Link*, context : Void*)
      fun pn_link_attachments(link : Link*) : Record*
      fun pn_link_name(link : Link*) : UInt8*
      fun pn_link_is_sender(link : Link*) : Bool
      fun pn_link_is_receiver(link : Link*) : Bool
      fun pn_link_state(link : Link*) : State
      fun pn_link_error(link : Link*) : Error*
      fun pn_link_condition(link : Link*) : Condition*
      fun pn_link_remote_condition(link : Link*) : Condition*
      fun pn_link_session(link : Link*) : Session*
      fun pn_link_head(connection : Connection*, state : State) : Link*
      fun pn_link_next(link : Link*, state : State) : Link*
      fun pn_link_open(link : Link*)
      fun pn_link_close(link : Link*)
      fun pn_link_detach(link : Link*)
      fun pn_link_source(link : Link*) : Terminus*
      fun pn_link_target(link : Link*) : Terminus*
      fun pn_link_remote_source(link : Link*) : Terminus*
      fun pn_link_remote_target(link : Link*) : Terminus*
      fun pn_link_current(link : Link*) : Delivery*
      fun pn_link_advance(link : Link*) : Bool
      fun pn_link_credit(link : Link*) : Int32
      fun pn_link_queued(link : Link*) : Int32
      fun pn_link_remote_credit(link : Link*) : Int32
      fun pn_link_get_drain(link : Link*) : Bool
      fun pn_link_drained(link : Link*) : Int32
      fun pn_link_available(link : Link*) : Int32
      fun pn_link_snd_settle_mode(link : Link*) : SenderSettleMode
      fun pn_link_rcv_settle_mode(link : Link*) : ReceiverSettleMode
      fun pn_link_set_snd_settle_mode(link : Link*, mode : SenderSettleMode)
      fun pn_link_set_rcv_settle_mode(link : Link*, mode : ReceiverSettleMode)
      fun pn_link_remote_snd_settle_mode(link : Link*) : SenderSettleMode
      fun pn_link_remote_rcv_settle_mode(link : Link*) : ReceiverSettleMode
      fun pn_link_unsettled(link : Link*) : Int32
      fun pn_unsettled_head(link : Link*) : Delivery*
      fun pn_unsettled_next(delivery : Delivery*) : Delivery*
      fun pn_link_offered(sender : Link*, credit : Int32)
      fun pn_link_send(sender : Link*, bytes : UInt8*, n : SizeT) : SSizeT
      fun pn_link_flow(receiver : Link*, credit : Int32)
      fun pn_link_drain(receiver : Link*, credit : Int32)
      fun pn_link_set_drain(receiver : Link*, drain : Bool)
      fun pn_link_recv(receiver : Link*, bytes : UInt8*, n : SizeT) : SSizeT
      fun pn_link_draining(receiver : Link*) : Bool
      fun pn_link_max_message_size(link : Link*) : UInt64
      fun pn_link_set_max_message_size(link : Link*, size : UInt64)
      fun pn_link_remote_max_message_size(link : Link*) : UInt64
      fun pn_link_properties(link : Link*) : Data*
      fun pn_link_remote_properties(link : Link*) : Data*

      fun pn_terminus_get_type(terminus : Terminus*) : TerminusType
      fun pn_terminus_set_type(terminus : Terminus*, type : TerminusType) : Int32
      fun pn_terminus_get_address(terminus : Terminus*) : UInt8*
      fun pn_terminus_set_address(terminus : Terminus*, address : UInt8*) : Int32
      fun pn_terminus_get_distribution_mode(terminus : Terminus*) : DistributionMode
      fun pn_terminus_set_distribution_mode(terminus : Terminus*, mode : DistributionMode) : Int32
      fun pn_terminus_get_durability(terminus : Terminus*) : Durability
      fun pn_terminus_set_durability(terminus : Terminus*, durability : Durability) : Int32
      fun pn_terminus_get_expiry_policy(terminus : Terminus*) : ExpiryPolicy
      fun pn_terminus_has_expiry_policy(terminus : Terminus*) : Bool
      fun pn_terminus_set_expiry_policy(terminus : Terminus*, policy : ExpiryPolicy) : Int32
      fun pn_terminus_get_timeout(terminus : Terminus*) : Seconds
      fun pn_terminus_set_timeout(terminus : Terminus*, timeout : Seconds) : Int32
      fun pn_terminus_is_dynamic(terminus : Terminus*) : Bool
      fun pn_terminus_set_dynamic(terminus : Terminus*, dynamic : Bool) : Int32
      fun pn_terminus_properties(terminus : Terminus*) : Data*
      fun pn_terminus_capabilities(terminus : Terminus*) : Data*
      fun pn_terminus_outcomes(terminus : Terminus*) : Data*
      fun pn_terminus_filter(terminus : Terminus*) : Data*
      fun pn_terminus_copy(terminus : Terminus*, src : Terminus*) : Int32

      fun pn_dtag(bytes : UInt8*, size : SizeT) : DeliveryTag
      fun pn_delivery(link : Link*, tag : DeliveryTag) : Delivery*
      fun pn_delivery_get_context(delivery : Delivery*) : Void*
      fun pn_delivery_set_context(delivery : Delivery*, context : Void*)
      fun pn_delivery_attachments(delivery : Delivery*) : Record*
      fun pn_delivery_tag(delivery : Delivery*) : DeliveryTag
      fun pn_delivery_link(delivery : Delivery*) : Link*
      fun pn_delivery_local(delivery : Delivery*) : Disposition*
      fun pn_delivery_local_state(delivery : Delivery*) : UInt64
      fun pn_delivery_remote(delivery : Delivery*) : Disposition*
      fun pn_delivery_remote_state(delivery : Delivery*) : UInt64
      fun pn_delivery_settled(delivery : Delivery*) : Bool
      fun pn_delivery_pending(delivery : Delivery*) : SizeT
      fun pn_delivery_partial(delivery : Delivery*) : Bool
      fun pn_delivery_aborted(delivery : Delivery*) : Bool
      fun pn_delivery_writable(delivery : Delivery*) : Bool
      fun pn_delivery_readable(delivery : Delivery*) : Bool
      fun pn_delivery_updated(delivery : Delivery*) : Bool
      fun pn_delivery_update(delivery : Delivery*, state : UInt64)
      fun pn_delivery_clear(delivery : Delivery*)
      fun pn_delivery_current(delivery : Delivery*) : Bool
      fun pn_delivery_abort(delivery : Delivery*)
      fun pn_delivery_settle(delivery : Delivery*)
      fun pn_delivery_dump(delivery : Delivery*)
      fun pn_delivery_buffered(delivery : Delivery*) : Bool
      fun pn_work_head(connection : Connection*) : Delivery*
      fun pn_work_next(delivery : Delivery*) : Delivery*

      fun pn_disposition_type(disposition : Disposition*) : UInt64
      fun pn_disposition_type_name(disposition_type : UInt64) : UInt8*
      fun pn_disposition_condition(disposition : Disposition*) : Condition*
      fun pn_disposition_data(disposition : Disposition*) : Data*
      fun pn_disposition_get_section_number(disposition : Disposition*) : UInt32
      fun pn_disposition_set_section_number(disposition : Disposition*, section_number : UInt32)
      fun pn_disposition_get_section_offset(disposition : Disposition*) : UInt64
      fun pn_disposition_set_section_offset(disposition : Disposition*, section_offset : UInt64)
      fun pn_disposition_is_failed(disposition : Disposition*) : Bool
      fun pn_disposition_set_failed(disposition : Disposition*, failed : Bool)
      fun pn_disposition_is_undeliverable(disposition : Disposition*) : Bool
      fun pn_disposition_set_undeliverable(disposition : Disposition*, undeliverable : Bool)
      fun pn_disposition_annotations(disposition : Disposition*) : Data*

      fun pn_transport : Transport*
      fun pn_transport_set_server(transport : Transport*)
      fun pn_transport_free(transport : Transport*)
      fun pn_transport_get_user(transport : Transport*) : UInt8*
      fun pn_transport_require_auth(transport : Transport*, required : Bool)
      fun pn_transport_is_authenticated(transport : Transport*) : Bool
      fun pn_transport_require_encryption(transport : Transport*, required : Bool)
      fun pn_transport_is_encrypted(transport : Transport*) : Bool
      fun pn_transport_condition(transport : Transport*) : Condition*
      fun pn_transport_logger(transport : Transport*) : Logger*
      fun pn_transport_error(transport : Transport*) : Error*
      fun pn_transport_bind(transport : Transport*, connection : Connection*) : Int32
      fun pn_transport_unbind(transport : Transport*) : Int32
      fun pn_transport_trace(transport : Transport*, trace : Trace)
      fun pn_transport_set_tracer(transport : Transport*, tracer : Tracer)
      fun pn_transport_get_tracer(transport : Transport*) : Tracer
      fun pn_transport_get_context(transport : Transport*) : Void*
      fun pn_transport_set_context(transport : Transport*, context : Void*)
      fun pn_transport_attachments(transport : Transport*) : Record*
      fun pn_transport_log(transport : Transport*, message : UInt8*)
      fun pn_transport_get_channel_max(transport : Transport*) : UInt16
      fun pn_transport_set_channel_max(transport : Transport*, channel_max : UInt16) : Int32
      fun pn_transport_remote_channel_max(transport : Transport*) : UInt16
      fun pn_transport_get_max_frame(transport : Transport*) : UInt32
      fun pn_transport_set_max_frame(transport : Transport*, size : UInt32)
      fun pn_transport_get_remote_max_frame(transport : Transport*) : UInt32
      fun pn_transport_get_idle_timeout(transport : Transport*) : Millis
      fun pn_transport_set_idle_timeout(transport : Transport*, timeout : Millis)
      fun pn_transport_get_remote_idle_timeout(transport : Transport*) : Millis
      fun pn_transport_input(transport : Transport*, bytes : UInt8*, available : SizeT) : SSizeT
      fun pn_transport_output(transport : Transport*, bytes : UInt8*, size : SizeT) : SSizeT
      fun pn_transport_capacity(transport : Transport*) : SSizeT
      fun pn_transport_tail(transport : Transport*) : UInt8*
      fun pn_transport_push(transport : Transport*, src : UInt8*, size : SizeT) : SSizeT
      fun pn_transport_process(transport : Transport*, size : SizeT) : Int32
      fun pn_transport_close_tail(transport : Transport*) : Int32
      fun pn_transport_pending(transport : Transport*) : SSizeT
      fun pn_transport_head(transport : Transport*) : UInt8*
      fun pn_transport_peek(transport : Transport*, dst : UInt8*, size : SizeT) : SSizeT
      fun pn_transport_pop(transport : Transport*, size : SizeT)
      fun pn_transport_close_head(transport : Transport*) : Int32
      fun pn_transport_quiesced(transport : Transport*) : Bool
      fun pn_transport_head_closed(transport : Transport*) : Bool
      fun pn_transport_tail_closed(transport : Transport*) : Bool
      fun pn_transport_closed(transport : Transport*) : Bool
      fun pn_transport_tick(transport : Transport*, now : Int64) : Int64
      fun pn_transport_get_frames_output(transport : Transport*) : UInt64
      fun pn_transport_get_frames_input(transport : Transport*) : UInt64
      fun pn_transport_connection(transport : Transport*) : Connection*

      fun pn_event_type_name(type : EventType) : UInt8*
      fun pn_collector : Collector*
      fun pn_collector_free(collector : Collector*)
      fun pn_collector_release(collector : Collector*)
      fun pn_collector_drain(collector : Collector*)
      fun pn_collector_put(collector : Collector*, clazz : Class*, context : Void*, type : EventType) : Event*
      fun pn_collector_put_object(collector : Collector*, object : Void*, type : EventType) : Event*
      fun pn_collector_peek(collector : Collector*) : Event*
      fun pn_collector_pop(collector : Collector*) : Bool
      fun pn_collector_next(collector : Collector*) : Event*
      fun pn_collector_prev(collector : Collector*) : Event*
      fun pn_collector_more(collector : Collector*) : Bool
      fun pn_event_type(event : Event*) : EventType
      fun pn_event_class(event : Event*) : Class*
      fun pn_event_context(event : Event*) : Void*
      fun pn_event_connection(event : Event*) : Connection*
      fun pn_event_session(event : Event*) : Session*
      fun pn_event_link(event : Event*) : Link*
      fun pn_event_delivery(event : Event*) : Delivery*
      fun pn_event_transport(event : Event*) : Transport*
      fun pn_event_attachments(event : Event*) : Record*
      fun pn_event_condition(event : Event*) : Condition*

      fun pn_connection_driver_init(driver : ConnectionDriver*, connection : Connection*, transport : Transport*) : Int32
      fun pn_connection_driver_bind(driver : ConnectionDriver*) : Int32
      fun pn_connection_driver_destroy(driver : ConnectionDriver*)
      fun pn_connection_driver_release_connection(driver : ConnectionDriver*) : Connection*
      fun pn_connection_driver_read_buffer_sized(driver : ConnectionDriver*, n : SizeT) : RWBytes
      fun pn_connection_driver_read_buffer(driver : ConnectionDriver*) : RWBytes
      fun pn_connection_driver_read_done(driver : ConnectionDriver*, n : SizeT)
      fun pn_connection_driver_read_close(driver : ConnectionDriver*)
      fun pn_connection_driver_read_closed(driver : ConnectionDriver*) : Bool
      fun pn_connection_driver_write_buffer(driver : ConnectionDriver*) : Bytes
      fun pn_connection_driver_write_done(driver : ConnectionDriver*, n : SizeT) : Bytes
      fun pn_connection_driver_write_close(driver : ConnectionDriver*)
      fun pn_connection_driver_write_closed(driver : ConnectionDriver*) : Bool
      fun pn_connection_driver_close(driver : ConnectionDriver*)
      fun pn_connection_driver_next_event(driver : ConnectionDriver*) : Event*
      fun pn_connection_driver_has_event(driver : ConnectionDriver*) : Bool
      fun pn_connection_driver_finished(driver : ConnectionDriver*) : Bool
      fun pn_connection_driver_log(driver : ConnectionDriver*, msg : UInt8*)
      fun pn_connection_driver_ptr(connection : Connection*) : ConnectionDriver**

      fun pn_sasl(transport : Transport*) : Sasl*
      fun pn_sasl_extended : Bool
      fun pn_sasl_done(sasl : Sasl*, outcome : SaslOutcome)
      fun pn_sasl_outcome(sasl : Sasl*) : SaslOutcome
      fun pn_sasl_get_user(sasl : Sasl*) : UInt8*
      fun pn_sasl_get_authorization(sasl : Sasl*) : UInt8*
      fun pn_sasl_get_mech(sasl : Sasl*) : UInt8*
      fun pn_sasl_allowed_mechs(sasl : Sasl*, mechs : UInt8*)
      fun pn_sasl_set_allow_insecure_mechs(sasl : Sasl*, insecure : Bool)
      fun pn_sasl_get_allow_insecure_mechs(sasl : Sasl*) : Bool
      fun pn_sasl_config_name(sasl : Sasl*, name : UInt8*)
      fun pn_sasl_config_path(sasl : Sasl*, path : UInt8*)
    end
  end
end
