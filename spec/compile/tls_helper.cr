require "../../src/qpid-proton/tls"

context = OpenSSL::SSL::Context::Client.new
factory = Qpid::Proton::TLS.io_factory(context)
client = Qpid::Proton::Client.new("localhost", 5671, io_factory: factory, externally_encrypted: true)

typeof(Qpid::Proton::Client.open("localhost", 5671, io_factory: factory, externally_encrypted: true) do |open_client|
  open_client.connected?
end)

client.close
