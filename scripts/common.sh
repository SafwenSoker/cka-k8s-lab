#!/usr/bin/env bash

if [ -z ${K8S_VERSION+x} ]; then
  K8S_VERSION=1.28.2-1.1
fi

 sudo modprobe overlay
sudo modprobe br_netfilter
sudo echo 'overlay' > /etc/modules-load.d/containerd.conf
sudo echo 'br_netfilter' >> /etc/modules-load.d/containerd.conf
sudo echo 'net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/kubernetes.conf
sudo echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/kubernetes.conf
sudo echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/kubernetes.conf
sudo sysctl --system

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
#    sudo mv ~/kubernetes.list /etc/apt/sources.list.d

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt update
echo "KUBELET_EXTRA_ARGS=--node-ip="$(ip addr show eth1  | awk '$1 == "inet" { print $2 }' | cut -d/ -f1) | sudo tee /etc/default/kubelet

sudo apt install -y containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install etcdctl
export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest|grep tag_name | cut -d '"' -f 4)
wget https://github.com/etcd-io/etcd/releases/download/${RELEASE}/etcd-${RELEASE}-linux-amd64.tar.gz
tar xvf etcd-${RELEASE}-linux-amd64.tar.gz
cd etcd-${RELEASE}-linux-amd64
sudo mv etcd etcdctl etcdutl /usr/local/bin

sudo apt install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION kubectl=$K8S_VERSION

sudo crictl config runtime-endpoint unix:///run/containerd/containerd.sock

sudo curl -L git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave

# Set alias for kubectl command
echo "alias k=kubectl" >> /home/vagrant/.bashrc
