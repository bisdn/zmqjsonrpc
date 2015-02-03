# more info here: http://guides.rubygems.org/specification-reference/

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "zmqjsonrpc"
  spec.version       = "0.1"
  spec.authors       = ["Tom Rothe"]
  spec.email         = ["tom@bisdn.de"]
  spec.description   = 'Simple JSON RPC 2.0 client and server via zmq.'
  spec.summary       = 'ZeroMQ JSON RPC client and server.'
  spec.homepage      = "https://github.com/bisdn/zmqjsonrpc"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = Dir.glob('test/*.rb')
  spec.require_paths = ["lib"]

  spec.add_dependency("ffi-rzmq", "~> 2.0.4")
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
