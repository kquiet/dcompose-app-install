# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu2204"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

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

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/tmp/dcompose-app-install",
    type: "9p",  #https://wiki.qemu.org/Documentation/9p
    readonly: true,
    mount_options: [
      "access=any",
      "version=9p2000.L"
    ]
    # type: "nfs",
    # readonly: true,
    # nfs_version: 4,
    # nfs_udp: false

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
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpu_mode = "host-passthrough"
    # libvirt.management_network_name = "vagrant-libvirt"
    # libvirt.management_network_address = "192.168.121.0/24"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  host_user = `whoami`.strip
  config.vm.provision "shell", inline: <<-SHELL
    # 1. Create the user if it doesn't exist
    if ! id "#{host_user}" &>/dev/null; then
      useradd -m -s /bin/bash #{host_user}
      # 2. Grant passwordless sudo (essential for Ansible)
      echo "#{host_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/#{host_user}
    fi
    # 3. Setup SSH directory
    USER_HOME="/home/#{host_user}"
    mkdir -p $USER_HOME/.ssh
    # 4. Inject public key
    echo "#{File.read(File.expand_path("~/.ssh/id-rsa-dcompose-app-install.pub"))}" > $USER_HOME/.ssh/authorized_keys
    # 5. Make sure permissions
    chown -R #{host_user}:#{host_user} $USER_HOME/.ssh
    chmod 700 $USER_HOME/.ssh
    chmod 600 $USER_HOME/.ssh/authorized_keys
  SHELL

  config.vm.define "vm01" do |node|
    node.vm.hostname = "vm01"
    node.vm.network "private_network", ip: "192.168.56.10"
    node.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 1
    end
  end
  config.vm.define "vm02" do |node|
    node.vm.hostname = "vm02"
    node.vm.network "private_network", ip: "192.168.56.11"
    node.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 1
    end
  end
  
end
