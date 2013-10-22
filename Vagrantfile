Vagrant.configure("2") do |config|
  config.vm.box = "saucy"
  config.ssh.username = "vagrant"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 7990, host: 7990
  config.vm.network :forwarded_port, guest: 8080, host: 8080

  config.vm.provider :virtualbox do |vb|
   vb.customize ["modifyvm", :id, "--memory", 2048]
  end

  #config.vm.provision :shell, :inline => "curl -Lks git.io/cfg | HOME=/home/vagrant bash", :privileged => false
end

