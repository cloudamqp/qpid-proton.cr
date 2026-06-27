require "openssl"
require "../../src/qpid-proton"

context = OpenSSL::SSL::Context::Client.new
client = Qpid::Proton::Client.new("localhost", 5671, tls_context: context)

typeof(Qpid::Proton::Client.open("localhost", 5671, tls_context: context) do |open_client|
  open_client.connected?
end)

client.close
