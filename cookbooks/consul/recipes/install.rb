user = "consul"
consul_zip = "/vagrant/tmp/consul.zip"

dir = "/opt/consul"
consul_bin = "#{dir}/current/consul"

group user do
end

user user do
  home dir
  shell "/bin/bash"
  gid user
end

directory dir do
  action :create
  owner user
  group user
  mode 0775
end

execute "install consul" do
  command "unzip #{consul_zip} -d #{dir}/current"
  user user
  group user
  only_if { ! ::File.exist? consul_bin }
end
