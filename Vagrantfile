# -*- mode: ruby -*-
# vi: set ft=ruby :

# this is sort of required on macs to fix a silly vagrant bug
# uncomment it out if you have issues and want to try a workaround
#require_relative 'network_interfaces'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  #
  # to use RHEL 7
  #config.vm.box = "demobuilder/rhel-server-7"
  # or default to CentOS 7
  config.vm.box = "centos/7"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", path: "provision.sh"

  config.vm.provision :reload

  config.vm.define "idm_1" do |idm_1|
    # The hostname the machine should have. Defaults to nil. If nil, Vagrant
    # won't manage the hostname. If set to a string, the hostname will be set
    # on boot.
    idm_1.vm.hostname = "idm-1.example.test"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    idm_1.vm.network "private_network", ip: "172.17.0.2", virtualbox__intnet: true

    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    idm_1.vm.provision "shell", path: "provision_idm_1.sh"

    # Forwarded ports allow you to access a port on your host machine and have
    # all data forwarded to a port on the guest machine, over either TCP or UDP.
    idm_1.vm.network "forwarded_port", guest: 80, host: 8080
    idm_1.vm.network "forwarded_port", guest: 443, host: 8443

    idm_1.vm.provider "virtualbox" do |v|
      v.memory = 3184
      v.cpus = 2
    end
  end

  config.vm.define "nfs" do |nfs|
    # The hostname the machine should have. Defaults to nil. If nil, Vagrant
    # won't manage the hostname. If set to a string, the hostname will be set
    # on boot.
    nfs.vm.hostname = "nfs.example.test"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    nfs.vm.network "private_network", ip: "172.17.0.4", virtualbox__intnet: true

    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    nfs.vm.provision "shell", path: "provision_nfs.sh"

    idm_1.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

  end

  config.vm.define "client7_1" do |client7_1|
    # The hostname the machine should have. Defaults to nil. If nil, Vagrant
    # won't manage the hostname. If set to a string, the hostname will be set
    # on boot.
    client7_1.vm.hostname = "client7-1.example.test"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    client7_1.vm.network "private_network", ip: "172.17.0.9", virtualbox__intnet: true

    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    client7_1.vm.provision "shell", path: "provision_client7_1.sh"

    idm_1.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end

  end

  # by default, don't create a centos 6 client
  # config.vm.define "client6_1" do |client6_1|
  #   # Every Vagrant development environment requires a box. You can search for
  #   # boxes at https://atlas.hashicorp.com/search.
  #   # to use RHEL 6
  #   #config.vm.box = "demobuilder/rhel-server-6"
  #   # or default to CentOS 6
  #   config.vm.box = "centos/centos6"
  #
  #   # The hostname the machine should have. Defaults to nil. If nil, Vagrant
  #   # won't manage the hostname. If set to a string, the hostname will be set
  #   # on boot.
  #   client6_1.vm.hostname = "client6-1.example.test"

  #   # Create a private network, which allows host-only access to the machine
  #   # using a specific IP.
  #   client6_1.vm.network "private_network", ip: "172.17.0.19", virtualbox__intnet: true

  #   # Enable provisioning with a shell script. Additional provisioners such as
  #   # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  #   # documentation for more information about their specific syntax and use.
  #   client6_1.vm.provision "shell", path: "provision_client6_1.sh"
  # end

end
