require 'ffi-rzmq'
require 'json'

module ZmqJsonRpc
  # This class implements the server:
  #
  # USE
  #   class Proxy
  #     def some_method(a,b)
  #       return [a,b,{"XXXX"=> 1}]
  #     end
  #   end
  #   server = ZmqJsonRpc::Server.new(Proxy.new())
  #   server.server_loop
  # 
  #
  # If you want a non blocking server do
  #   server = ZmqJsonRpc::Server.new(Proxy.new())
  #   thread = Thread.new {
  #     server.server_loop
  #   }
  #  # later either do
  #  thread.join # waiting for the server to finish -- which is never!
  #  # or
  #  thread.exit # or end the thread
  class Server
    # For errors the spec says:
    # The error codes from and including -32768 to -32000 are reserved for pre-defined errors. Any code within this range, but not defined explicitly below is reserved for future use. The error codes are nearly the same as those suggested for XML-RPC at the following url: http://xmlrpc-epi.sourceforge.net/specs/rfc.fault_codes.php
    #
    # For details on the zmq gem, please see https://github.com/chuckremes/ffi-rzmq (best to look in the code)
    def initialize(proxy, connect="tcp://*:49200", logger=nil)
      @connect = connect
      @proxy = proxy
      @logger = logger
    end
  
    def handle_request(request)
      begin
        req_id = nil
        rpc = JSON.parse(request)
        raise "Received unsupprted jsonrpc version (#{rpc['jsonrpc']})" if rpc["jsonrpc"].strip != "2.0"
        rid = rpc["id"]
        method = rpc["method"]
        params = rpc["params"]

        @logger.info "Received JSON RPC request: #{method}(#{params.collect {|p| p.inspect}.join(", ")})" unless @logger.nil?
        result = @proxy.send(method.to_sym, *params)
        response = {
          id: rid,
          jsonrpc: "2.0",
          result: result
        }
        return response.to_json
      rescue => e
        # If there is more time to spare, we could implement the actual error codes here.
        @logger.warn "Returning error for RPC request: #{e.message})" unless @logger.nil?
        response = {
          id: rid,
          jsonrpc: "2.0",
          error: {
            code: 32603,
            message: e.message,
            data: e.backtrace.inspect
          }
        }
        return response.to_json
      end
    end

    def server_loop
      @context = ZMQ::Context.new(1)
      @socket = @context.socket(ZMQ::REP)
      @socket.bind(@connect)
      begin
        loop do
          request = ''
          rc = @socket.recv_string(request)
          response = handle_request(request)
          @socket.send_string(response)
        end
      ensure
        @socket.close
        # @context.terminate
      end
    end
  end
end