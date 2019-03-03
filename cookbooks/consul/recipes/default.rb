user = "consul"
consul_zip = "/vagrant/tmp/consul.zip"
dir = "/opt/consul"
consul_bin = "#{dir}/current/consul"
config_file = "#{dir}/config.hcl"
encryption_key = "bL/xPRcn6z4vyzmiDDqPZA=="

listen_ip = nil
node[:network][:interfaces][:eth1][:addresses].each do |k, v|
  if ! v['family'].nil? && v['family'] == 'inet'
    listen_ip = k
  end
end
if listen_ip.nil?
  raise "can't find listen ip"
end

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

server_lists = ["10.11.12.11", "10.11.12.12", "10.11.12.13"]
selected = server_lists.select { |item| item != listen_ip }

file config_file do
  content <<~EOF
    data_dir = "#{dir}/data"
    bind_addr = "#{listen_ip}"
    encrypt = "#{encryption_key}"

    datacenter = "mydc"
    node_name = "#{listen_ip}"

    server = true
    retry_join = #{selected}
    bootstrap_expect = 3

    ui = true
    client_addr = "0.0.0.0"
  EOF
  user user
  group user
  mode 0775
  action :create
end

systemd_unit 'consul.service' do
  content <<~EOF
    [Unit]
    Description="HashiCorp Consul - A service mesh solution"
    Documentation=https://www.consul.io/
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=#{config_file}

    [Service]
    User=consul
    Group=consul
    ExecStart=#{consul_bin} agent -config-dir=#{dir} -config-format=hcl
    ExecReload=#{consul_bin} reload
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target
  EOF

  action [:create, :enable, :restart]
end
