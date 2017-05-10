
# For a complete reference, please see the online documentation at
# https://docs.vagrantup.com.

Vagrant.configure("2") do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.127.127"


  # vb.customize does not returns output from the command
  id_file = ".vagrant/machines/default/virtualbox/id"
  # don't know the id, can't search for the controller name
  # using the default on the config.vm.box and hoping for the best
  floppy_controller = "Floppy Controller Controller"
  has_cdrom = false

  # doesn't exist until VM is provisioned the first time
  if FileTest.exist?(id_file) and FileTest.readable?(id_file)
    # unsetting, if nothing is found no need to remove again
    floppy_controller = ""
    id = File.read(id_file)
    output = `VBoxManage showvminfo #{id}`
    previous_line = ''

    for line in output.each_line
      if line =~ /I82078/
        floppy_controller = (previous_line.gsub(/\s/, '').split(':'))[1]
      elsif line =~ /^SATA\sController\s\(1,\s0\)\:\sEmpty/
          has_cdrom = true
      else
        previous_line = line
      end
    end
  end

  config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     # Might be useful, but not required, so leaving commented
     # vb.gui = true
     # Customize the amount of memory on the VM:
     vb.memory = "1024"
     # Giving a nice name to it
     vb.name = "CPAN Testers - Development"
     # see https://www.virtualbox.org/manual/ch08.html
     # configure the minimum memory for video (set to 8MB originally)
     vb.customize ["modifyvm", :id, "--vram", "9"]
     # This needs to be set as idempotent change
     # remove the floppy
     unless floppy_controller.empty?
       vb.customize ["storagectl", :id, "--name", floppy_controller, "--remove"]
     end
     # adds a CDROM
     # also assumes config.vm.box has a single SATA HD in port 0
     unless has_cdrom
       vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "1", "--medium", "emptydrive"]
     end
  end

  # Guest Additions handling
  config.vm.provision "shell", inline: "apt-get update;apt-get -y upgrade;apt-get -y install module-assistant;m-a prepare --text-mode --non-inter"
  # set auto_update to false, if you do NOT want to check the correct 
  # additions version when booting this machine
  #config.vbguest.auto_update = false
  # do NOT download the iso file from a webserver
  #config.vbguest.no_remote = true
  # if you want to install x-window, you will have to comment this and
  # reinstall the Guest Additions yourself
  config.vbguest.installer_arguments = ['--nox11']

  config.vm.post_up_message = "CPAN Testers VM update and running. See https://github.com/cpan-testers/cpantesters-deploy for more information."

end

# -*- mode: ruby -*-
# vi: set ft=ruby :
