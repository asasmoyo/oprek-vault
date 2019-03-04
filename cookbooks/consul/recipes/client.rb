include_recipe '::install'

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

file config_file do
  content <<~EOF
    data_dir = "#{dir}/data"
    bind_addr = "#{listen_ip}"
    client_addr = "0.0.0.0"
    encrypt = "#{encryption_key}"

    datacenter = "mydc"
    node_name = "#{listen_ip}"
    retry_join = ["10.11.12.11", "10.11.12.12", "10.11.12.13"]

    ui = true
  EOF
  user user
  group user
  mode 0775
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
