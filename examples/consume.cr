require "../src/qpid-proton"

host = ENV["AMQP_HOST"]? || "localhost"
port = (ENV["AMQP_PORT"]? || "5672").to_i
username = ENV["AMQP_USERNAME"]?
password = ENV["AMQP_PASSWORD"]?
allow_insecure = ENV["AMQP_ALLOW_INSECURE_MECHS"]? == "1"
address = ARGV[0]? || "examples"

Qpid::Proton::Client.open(host, port, username: username, password: password, allow_insecure_mechanisms: allow_insecure) do |client|
  client.consume(address) do |message|
    puts message.body_string || message.body.format
  end
end
