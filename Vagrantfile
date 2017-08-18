# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  #config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.synced_folder ".", "/data"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 1
  end


  config.vm.provision :shell, :privileged => false, :inline => "bash /data/vagrant/setup1.sh"
  config.vm.provision :shell, :privileged => false, :inline => "bash /data/vagrant/setup2_backend.sh"
  config.vm.provision :shell, :privileged => false, :inline => "bash /data/vagrant/setup3_frontend.sh"
  config.vm.provision :shell, :privileged => false, :inline => "bash /data/vagrant/setup4_front_back_link.sh"
  config.vm.network "forwarded_port", guest: 80, host: 8888

  config.trigger.before :destroy do
   info "Cleaning up local files..."
   run_remote  "bash /data/vagrant/vagrant_cleanup.sh"
  end
end
