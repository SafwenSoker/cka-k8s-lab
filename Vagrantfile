BOX_IMAGE = "generic/ubuntu2204"
WORKER_COUNT = 2
HOST_IP_BASE = "192.168.56"
CONTROL_NODE_IP = "#{HOST_IP_BASE}.10"
POD_CIDR = "10.32.0.0/12"

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE

  config.vm.define "kube-control-plane" do |node|
    node.vm.hostname = "kube-control-plane"
    node.vm.network :private_network, ip: "#{CONTROL_NODE_IP}"
    node.vm.provider :virtualbox do |vb|
      vb.name = "kube-control-plane"
      vb.memory = 2048
      vb.cpus = 2
    end
    node.vm.provision "shell", path: "scripts/common.sh"
  end

  (1..WORKER_COUNT).each do |i|
    WORKER_NODE_IP = "#{HOST_IP_BASE}.#{i + 10}"

    config.vm.define "kube-node#{i}" do |node|
      node.vm.hostname = "kube-node#{i}"
      node.vm.network :private_network, ip: "#{WORKER_NODE_IP}"
      node.vm.provider :virtualbox do |vb|
        vb.name = "kube-node#{i}"
        vb.memory = 2048
        vb.cpus = 1
      end
      node.vm.provision "shell", path: "scripts/common.sh"
    end
  end

  config.vm.provision "shell",
    run: "always",
    inline: "swapoff -a"
end
