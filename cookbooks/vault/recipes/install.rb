vault_zip = '/vagrant/tmp/vault.zip'

group node[:vault][:user] do
end

user node[:vault][:user] do
  home node[:vault][:dir]
  shell "/bin/bash"
  gid node[:vault][:user]
end

directory node[:vault][:dir] do
  action :create
  owner node[:vault][:user]
  group node[:vault][:user]
  mode 0770
end

execute "install vault" do
  command "unzip #{vault_zip} -d #{node[:vault][:dir]}/current"
  user node[:vault][:user]
  group node[:vault][:user]
  only_if { ! ::File.exist? node[:vault][:bin] }
end
