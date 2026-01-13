
# For a complete reference, please see the online documentation at
# https://docs.vagrantup.com.
  # Vagrantfile for setting up a 3-node K3s Kubernetes cluster (1 manager, 2 agents)

Vagrant.configure("2") do |config|
  # Define a common base configuration for all VMs
  config.vm.box = "cloud-image/debian-13" # Debian Trixie
  config.vm.box_version = "20251117.2299.0"

  # Define the manager node
  config.vm.define "k3s-server" do |server|
    server.vm.hostname = "k3s-server"
    server.vm.network "private_network", ip: "192.168.56.10"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    server.vm.provision "shell", path: "bin/k3s-server.sh"
  end

  # Define the first agent node
  config.vm.define "k3s-agent1" do |agent1|
    agent1.vm.hostname = "k3s-agent1"
    agent1.vm.network "private_network", ip: "192.168.56.11"
    agent1.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    agent1.vm.provision "shell", path: "bin/k3s-agent.sh", args: ["192.168.56.10"]
  end

  # Define the second agent node
  config.vm.define "k3s-agent2" do |agent2|
    agent2.vm.hostname = "k3s-agent2"
    agent2.vm.network "private_network", ip: "192.168.56.12"
    agent2.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
    agent2.vm.provision "shell", path: "bin/k3s-agent.sh", args: ["192.168.56.10"]
  end

end

# -*- mode: ruby -*-
# vi: set ft=ruby :
