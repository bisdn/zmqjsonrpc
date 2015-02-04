# zmqjsonrpc [![Gem Version](https://img.shields.io/gem/v/zmqjsonrpc.svg)](https://rubygems.org/gems/zmqjsonrpc)

This gem implements a very simple [JSON RPC 2.0](http://www.jsonrpc.org/specification) client and server which uses zeroMQ for transport.
Let's not talk too much, let's see some code:

```ruby
  require 'rubygems'
  require 'zmqjsonrpc'
  
  # client request to a running server
  client = ZmqJsonRpc::Client.new("tcp://127.0.0.1:49200")
  client.some_method(1, "b", [1,{a:1}])
```

```ruby
  require 'rubygems'
  require 'zmqjsonrpc'

  class Proxy
    def some_method(a,b,c)
      # do you thing
      return ["xyz", 77]
    end
  end

  # blocking server
  proxy = Proxy.new()
  server = ZmqJsonRpc::Server.new(proxy, "tcp://*:49200")
  server.server_loop
  
  # -or- dispatch a thread
  server = ZmqJsonRpc::Server.new(proxy, "tcp://*:49200")
  thread = Thread.new {
    server.server_loop
  }
  # and cancel the thread if you want to shut the server down
  thread.exit
```

## Resources

* The [JSON RPC 2.0 Spec](http://www.jsonrpc.org/specification)
* The used [ZeroMQ gem](https://github.com/chuckremes/ffi-rzmq) and [good examples](http://github.com/andrewvc/learn-ruby-zeromq)
* [Gem making](http://guides.rubygems.org/make-your-own-gem/)

## Stuff left to do

* Add support for by-name parameters (see [the spec](http://www.jsonrpc.org/specification#parameter_structures))
* Add individual exception classes in the client.
* Send different error codes if something goes wrong in the server.
* Keep the client connection alive instead of re-establishing every time.
* Add more tests.

## Licence

This code is released under the terms of MIT License.

## Contribute

Please do so! Just send a message or send a pull request.
Especially, adding webrick for transport would be nice.