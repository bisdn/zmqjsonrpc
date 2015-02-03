require 'test/unit'
require "logger"
require "stringio"
require_relative '../lib/zmqjsonrpc'

class TestClientServer < Test::Unit::TestCase
  def setup
    @buffer = StringIO.new
    @logger = Logger.new(@buffer)
    @logger.level = Logger::WARN
  end
  
  def assert_empty_log
    @buffer.seek(0)
    assert_equal @buffer.read, "", "Server log included warnings."
  end
  
  def test_client_with_server
    proxy_class = Class.new() do
      def initialize(test_case)
        @test_case = test_case
        @method_was_called = false
      end
      def method_was_called?
        return @method_was_called
      end

      def some_method(a,b,c)
        @test_case.assert_equal a, 1
        @test_case.assert_equal b, "b"
        @test_case.assert_equal c, [1,{"a" => 1}]
        @method_was_called = true
        return "abc"
      end
    end

    proxy = proxy_class.new(self)
    server = ZmqJsonRpc::Server.new(proxy, "tcp://*:49200", @logger)
    thread = Thread.new {
      server.server_loop
    }
    client = ZmqJsonRpc::Client.new("tcp://127.0.0.1:49200")
    assert_equal client.some_method(1, "b", [1,{a:1}]), "abc"
    assert proxy.method_was_called?, "Server method was not called"

    assert_raise ZmqJsonRpc::ClientError do
      client.fishy_method()
    end

    thread.exit
  end
end