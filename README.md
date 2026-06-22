# qpid-proton.cr

Crystal bindings for the Apache Qpid Proton C library, plus a small blocking client for AMQP 1.0 publish/consume workflows.

The shard links against `libqpid-proton` and expects Proton headers and libraries to be installed on the system.
The high-level client uses Proton's `pn_connection_driver` over a Crystal `TCPSocket`.

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
crystal run examples/publish.cr -- examples "hello"
crystal run examples/consume.cr -- examples
```

Set `AMQP_HOST`, `AMQP_PORT`, `AMQP_USERNAME`, `AMQP_PASSWORD`, and `AMQP_ALLOW_INSECURE_MECHS=1` as needed.
