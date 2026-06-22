require "../src/qpid-proton"

host = ENV["AMQP_HOST"]? || "localhost"
port = (ENV["AMQP_PORT"]? || "5672").to_i
username = ENV["AMQP_USERNAME"]?
password = ENV["AMQP_PASSWORD"]?
allow_insecure = ENV["AMQP_ALLOW_INSECURE_MECHS"]? == "1"
address = ARGV[0]? || "examples"
body = ARGV[1]? || "hello from Crystal"

Qpid::Proton::Client.open(host, port, username: username, password: password, allow_insecure_mechanisms: allow_insecure) do |client|
  client.publish(address, body)
end
