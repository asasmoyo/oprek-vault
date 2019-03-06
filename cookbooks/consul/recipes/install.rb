consul_zip = "/vagrant/tmp/consul.zip"

group node[:consul][:user] do
end

user node[:consul][:user] do
  home node[:consul][:dir]
  shell "/bin/bash"
  gid node[:consul][:user]
end

directory node[:consul][:dir] do
  action :create
  owner node[:consul][:user]
  group node[:consul][:user]
  mode 0775
end

execute "install consul" do
  command "unzip #{consul_zip} -d #{node[:consul][:dir]}/current"
  user node[:consul][:user]
  group node[:consul][:user]
  only_if { ! ::File.exist? node[:consul][:bin] }
end
