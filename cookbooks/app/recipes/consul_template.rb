consul_template_zip = '/vagrant/tmp/consul-template.zip'

directory node[:consul_template][:dir] do
  action :create
  owner node[:consul][:user]
  group node[:consul][:user]
  mode 0775
end

directory node[:consul_template][:config_dir] do
  action :create
  owner node[:consul][:user]
  group node[:consul][:user]
  mode 0775
end

directory node[:consul_template][:template_dir] do
  action :create
  owner node[:consul][:user]
  group node[:consul][:user]
  mode 0775
end

execute "install consul template" do
  command "unzip #{consul_template_zip} -d #{node[:consul_template][:dir]}/current"
  user node[:consul][:user]
  group node[:consul][:user]
  only_if { ! ::File.exist? node[:consul_template][:bin] }
end

systemd_unit 'consul-template.service' do
  content <<~EOF
    [Unit]
    Description="Consul Template"
    Documentation=https://www.consul.io/
    Requires=network-online.target
    After=network-online.target

    [Service]
    User=root
    Group=root
    ExecStart=#{node[:consul_template][:bin]} -config=#{node[:consul_template][:config_dir]}
    ExecReload=/bin/kill -SIGHUP $MAINPID
    ExecStop=/bin/kill -SIGINT $MAINPID
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target
  EOF
  verify false
  action [:create, :enable, :restart]
end
