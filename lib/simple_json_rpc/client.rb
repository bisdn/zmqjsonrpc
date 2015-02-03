require 'json'
require 'securerandom'

module ZmqJsonRpc
  class ClientError < RuntimeError
  end
  
  # You shall instanciate this class with a connect string which follows the zeroMQ conventions: http://api.zeromq.org/2-1:zmq-connect
  # After connecting you can call any method on this class and it will be sent to the server.
  # If something goes wrong ZmqJsonRpc::ClientError is thrown.
  # timeout is measured in milliseconds.
  # 
  # NOTE
  # The client does not keep the connection alive. For each request, a new connection is esablished and torn down after the response.
  # This could become a performance issue.
  class Client
    def initialize(connect="tcp://127.0.0.1:49200", timeout=10000)
      @connect = connect
      @timeout = timeout
    end

    def send_rpc(method, params=[])
      begin
        # connect socket
        @context = ZMQ::Context.new(1)
        @socket = @context.socket(ZMQ::REQ)
        @socket.connect(@connect)
        @socket.setsockopt(ZMQ::SNDTIMEO, @timeout)
        @socket.setsockopt(ZMQ::RCVTIMEO, @timeout)

        # build and send request
        req_id = SecureRandom.uuid
        request = {
          id: req_id,
          jsonrpc: "2.0",
          method: method.to_s,
          params: params
        }        
        rc = @socket.send_string(request.to_json) # this will always succeed, even if the server is not reachable.

        # interpret response
        response = ''
        rc = @socket.recv_string(response)
        raise "Could talk to the server (server unreachable? time out?)" if rc < 0
        resjson = JSON.parse(response)
        # check response
        raise "Response's id did not match the sent id" if resjson["id"] != req_id
        raise "Response's version number is not supported (#{resjson["jsonrpc"]})" if resjson["jsonrpc"].strip != "2.0"
        raise "Server returned error (#{resjson["error"]["code"] || "?"}): #{resjson["error"]["message"]}\n#{resjson["error"]["data"]}" if resjson["error"]
        
        return resjson["result"]
      rescue => e
        raise ClientError, e.message
      ensure
        @socket.close rescue ''
      end
    end
    
    def method_missing(meth, *args, &block)
      self.send_rpc(meth, args)
    end
  end
end