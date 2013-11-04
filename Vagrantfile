Vagrant.configure("2") do |config|
  config.vm.box = "saucy"
  config.ssh.username = "vagrant"
  #config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/quantal/current/quantal-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 7990, host: 7990
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 8095, host: 8095

  config.vm.provider :virtualbox do |vb|
   vb.customize ["modifyvm", :id, "--memory", 3072]
  end

  config.vm.provision :shell, :inline => "curl -Lks git.io/cfg | HOME=/home/vagrant bash", :privileged => false

$dockerinstall = <<SCRIPT
echo Installing Docker...
sudo apt-get update
sudo apt-get install linux-image-extra-`uname -r` -y -q
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker -y -q
echo Docker installed...
SCRIPT

  config.vm.provision :shell, :inline => $dockerinstall, :privileged => false
end

