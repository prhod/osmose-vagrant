# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  #config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.synced_folder ".", "/data"

  config.vm.provision :shell, :privileged => false, :inline => "sh /data/setup.sh"
  config.vm.provision :shell, :privileged => false, :inline => "sh /data/setup_backend.sh"
  config.vm.provision :shell, :privileged => false, :inline => "sh /data/setup_frontend.sh"
  config.vm.network "forwarded_port", guest: 80, host: 8888
end
