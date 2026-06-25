# qpid-proton.cr

Crystal bindings for the Apache Qpid Proton C library, plus a small blocking client for AMQP 1.0 publish/consume workflows.

By default the shard builds and statically links a vendored Apache Qpid Proton C core from `vendor/qpid-proton`.
The vendored build disables Proton TLS and Cyrus SASL (`SSL_IMPL=none`, `SASL_IMPL=none`) and is intended for the core connection-driver/client workflow.
Compile with `-Dqpid_proton_system` to use the system `libqpid-proton` instead.

The high-level client uses Proton's `pn_connection_driver` over a Crystal `IO`.

```crystal
require "qpid-proton"

Qpid::Proton::Client.open("localhost", 5672) do |client|
  client.publish("examples", "hello")

  if message = client.receive("examples")
    puts message.body_string
  end
end
```

## Low-Level API

`Qpid::Proton::Lib` exposes raw FFI bindings for the core Proton C API. The wrapper classes manage common ownership and error handling:

- `Qpid::Proton::Message`
- `Qpid::Proton::Data`
- `Qpid::Proton::Connection`, `Session`, `Link`, `Delivery`
- `Qpid::Proton::Transport`, `Collector`, `Event`
- `Qpid::Proton::ConnectionDriver`

## Client API

```crystal
client = Qpid::Proton::Client.new(
  "localhost",
  5672,
  username: "guest",
  password: "guest",
  allow_insecure_mechanisms: true
)
client.connect
client.publish("queue-name", "payload")
message = client.receive("queue-name")
client.close
```

To connect through an externally wrapped IO, pass `io_factory`. If the IO is already encrypted, set `externally_encrypted: true` so Proton can use SASL mechanisms such as `PLAIN` even though Proton's own transport does not see TLS:

```crystal
factory = ->(host : String, port : Int32, timeout : Time::Span) {
  socket = TCPSocket.new(host, port, nil, timeout)
  socket.as(IO)
}

client = Qpid::Proton::Client.new(
  "localhost",
  5672,
  io_factory: factory,
  externally_encrypted: true
)
```

TLS support is optional and lives outside Proton:

```crystal
require "qpid-proton/tls"

client = Qpid::Proton::Client.new(
  "localhost",
  5671,
  io_factory: Qpid::Proton::TLS.io_factory,
  externally_encrypted: true
)
```

For manual delivery settlement:

```crystal
if incoming = client.receive_delivery("queue-name", auto_accept: false)
  begin
    process(incoming.message)
    incoming.accept
  rescue
    incoming.release
  end
end
```

## Examples

```sh
sh ./ext/qpid-proton/build.sh
crystal run examples/publish.cr -- examples "hello"
crystal run examples/consume.cr -- examples
```

Set `AMQP_HOST`, `AMQP_PORT`, `AMQP_USERNAME`, `AMQP_PASSWORD`, and `AMQP_ALLOW_INSECURE_MECHS=1` as needed.

If postinstall scripts are skipped, run `sh ./ext/qpid-proton/build.sh` before compiling, or compile with `-Dqpid_proton_system` to link against an installed Proton library.
