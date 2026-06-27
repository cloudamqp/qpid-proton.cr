require "./spec_helper"

describe Qpid::Proton do
  it "reports the bound Proton C library version constants" do
    Qpid::Proton::LIB_VERSION.should eq("0.40.0")
  end

  it "formats AMQP client addresses" do
    Qpid::Proton::Client.address("localhost", 5672).should eq("localhost:5672")
  end
end

describe Qpid::Proton::Data do
  it "stores and reads scalar AMQP values" do
    data = Qpid::Proton::Data.new
    data.put_string("hello")
    data.rewind

    data.next.should be_true
    data.type.should eq(Qpid::Proton::Lib::Type::String)
    data.string.should eq("hello")
  end

  it "encodes and decodes AMQP data" do
    data = Qpid::Proton::Data.new
    data.put(42)

    copy = Qpid::Proton::Data.new
    copy.decode(data.encode)
    copy.rewind

    copy.next.should be_true
    copy.int.should eq(42)
  end
end

describe Qpid::Proton::Message do
  it "round-trips encoded messages" do
    message = Qpid::Proton::Message.new
    message.subject = "greeting"
    message.address = "examples"
    message.body = "hello"

    copy = Qpid::Proton::Message.decode(message.encode)
    copy.subject.should eq("greeting")
    copy.address.should eq("examples")
    copy.body_string.should eq("hello")
  end
end

describe Qpid::Proton::Connection do
  it "opens sessions and links without a transport" do
    connection = Qpid::Proton::Connection.new
    session = connection.session
    sender = session.sender("sender")

    sender.target.address = "examples"
    connection.open
    session.open
    sender.open

    connection.local_active?.should be_true
    session.local_active?.should be_true
    sender.local_active?.should be_true
    sender.target.address.should eq("examples")
  end
end

describe Qpid::Proton::Client do
  it "can be created and closed without connecting" do
    client = Qpid::Proton::Client.new("localhost")
    client.closed?.should be_false
    client.close
    client.closed?.should be_true
  end

  it "type-checks high-level publish and consume methods" do
    client = Qpid::Proton::Client.new("localhost")
    typeof(client.publish("examples", "hello", 1.millisecond, false)).should eq(UInt64)
    typeof(client.receive("examples", 1.millisecond, 1)).should eq(Qpid::Proton::Message?)
    typeof(client.receive_delivery("examples", 1.millisecond, 1, auto_accept: false)).should eq(Qpid::Proton::IncomingMessage?)
    client.close
  end

  it "type-checks custom IO" do
    client = Qpid::Proton::Client.new(io: IO::Memory.new)

    typeof(Qpid::Proton::Client.open(io: IO::Memory.new) { |open_client| open_client.closed? }).should eq(Bool)
    client.close
  end

  it "type-checks externally encrypted clients" do
    client = Qpid::Proton::Client.new(io: IO::Memory.new, externally_encrypted: true)

    typeof(Qpid::Proton::Client.open(io: IO::Memory.new, externally_encrypted: true) { |open_client| open_client.connected? }).should eq(Bool)
    client.close
  end
end
