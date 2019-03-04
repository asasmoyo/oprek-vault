Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.define "app" do |app|
    app.vm.hostname = 'app'
    app.vm.network "private_network", ip: "10.11.12.10"
    app.vm.provision "chef_solo" do |chef|
      chef.add_recipe "common"
      chef.add_recipe "consul::client"
      chef.add_recipe "app"
    end
  end

  config.vm.define "node1" do |node1|
    node1.vm.hostname = 'node1'
    node1.vm.network "private_network", ip: "10.11.12.11"
    node1.vm.provision "chef_solo" do |chef|
      chef.add_recipe "common"
      chef.add_recipe "consul::server"
      chef.add_recipe "vault"
    end
  end

  config.vm.define "node2" do |node2|
    node2.vm.hostname = 'node2'
    node2.vm.network "private_network", ip: "10.11.12.12"
    node2.vm.provision "chef_solo" do |chef|
      chef.add_recipe "common"
      chef.add_recipe "consul::server"
      chef.add_recipe "vault"
    end
  end

  config.vm.define "node3" do |node3|
    node3.vm.hostname = 'node3'
    node3.vm.network "private_network", ip: "10.11.12.13"
    node3.vm.provision "chef_solo" do |chef|
      chef.add_recipe "common"
      chef.add_recipe "consul::server"
      chef.add_recipe "vault"
    end
  end
end
