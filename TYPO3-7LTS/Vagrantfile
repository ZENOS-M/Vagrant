VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    
    config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
    end

  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", ip: "192.168.33.22"

  config.vm.synced_folder "./", "/var/www/html", id: "vagrant-root", :owner => "www-data", :group => "www-data"

  config.vm.provision :shell, path: "bootstrap.sh"

end