Vagrant::Config.run do |config|
  config.vm.box = "raring"
  config.vm.box_url = "http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-vagrant-amd64-disk1.box"
  config.vm.forward_port 7990, 7991
  config.vm.share_folder("v-root", "/vagrant", ".")
  Vagrant::Config.run do |config|
    config.vm.customize ["modifyvm", :id, "--memory", 2048]
  end
end
