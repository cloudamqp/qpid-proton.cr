require "openssl"
require "../qpid/proton"

module Qpid
  module Proton
    module TLS
      def self.io_factory(context : OpenSSL::SSL::Context::Client = OpenSSL::SSL::Context::Client.new,
                          sync_close = true, hostname : String? = nil) : Client::IOFactory
        ->(host : String, port : Int32, timeout : Time::Span) do
          socket = nil

          begin
            socket = TCPSocket.new(host, port, nil, timeout)
            socket.read_timeout = timeout
            socket.write_timeout = timeout
            OpenSSL::SSL::Socket::Client.new(
              socket,
              context,
              sync_close: sync_close,
              hostname: hostname || host
            ).as(IO)
          rescue ex
            socket.try &.close
            raise ex
          end
        end
      end
    end
  end
end
