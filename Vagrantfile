Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "common"
    chef.add_recipe "vault"
  end

  config.vm.define "node1" do |node1|
    node1.vm.network "private_network", ip: "10.11.12.11"
  end

  config.vm.define "node2" do |node2|
    node2.vm.network "private_network", ip: "10.11.12.12"
  end

  config.vm.define "node3" do |node3|
    node3.vm.network "private_network", ip: "10.11.12.13"
  end
end
