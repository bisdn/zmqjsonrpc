# -*- mode: ruby -*-
# vi: set ft=ruby :

provision = <<SCRIPT
# Update system
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential git

# ruby
sudo apt-get -y install ruby2.0 ruby2.0-dev bundler rake
sudo ln -sf /usr/bin/ruby2.0 /usr/bin/ruby # make ruby 2 default
sudo ln -sf /usr/bin/gem2.0 /usr/bin/gem
sudo ln -sf /usr/bin/irb2.0 /usr/bin/irb

# install tools for development
sudo apt-get -y install vim man

# install dependencies
sudo apt-get install libzmq3 libzmq3-dev
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "simplejsonrpc"
  config.vm.provision :shell, inline: provision

  config.vm.provider "virtualbox" do |vb|
    vb.name = "simplejsonrpc"
  end
end
