require "openssl"
require "../../src/qpid-proton"

context = OpenSSL::SSL::Context::Client.new
typeof(begin
  socket = TCPSocket.new("localhost", 5671)
  tls_socket = OpenSSL::SSL::Socket::Client.new(socket, context, sync_close: true, hostname: "localhost")

  Qpid::Proton::Client.open(io: tls_socket, externally_encrypted: true, virtual_host: "localhost") do |open_client|
    open_client.connected?
  end
end)
