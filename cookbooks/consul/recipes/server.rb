include_recipe '::install'

listen_ip = nil
node[:network][:interfaces][:eth1][:addresses].each do |k, v|
  if ! v['family'].nil? && v['family'] == 'inet'
    listen_ip = k
  end
end
if listen_ip.nil?
  raise "can't find listen ip"
end

server_lists = ["10.11.12.11", "10.11.12.12", "10.11.12.13"]
selected = server_lists.select { |item| item != listen_ip }

file node[:consul][:config_file] do
  content <<~EOF
    data_dir = "#{node[:consul][:dir]}"
    bind_addr = "#{listen_ip}"
    client_addr = "0.0.0.0"
    encrypt = "#{node[:consul][:encryption_key]}"

    datacenter = "#{node[:consul][:dc]}"
    node_name = "#{listen_ip}"

    server = true
    retry_join = #{selected}
    bootstrap_expect = 3

    ui = true
  EOF
  user node[:consul][:user]
  group node[:consul][:user]
  mode 0664
end

systemd_unit 'consul.service' do
  content <<~EOF
    [Unit]
    Description="HashiCorp Consul - A service mesh solution"
    Documentation=https://www.consul.io/
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=#{node[:consul][:config_file]}

    [Service]
    User=#{node[:consul][:user]}
    Group=#{node[:consul][:user]}
    ExecStart=#{node[:consul][:bin]} agent -config-dir=#{node[:consul][:dir]} -config-format=hcl
    ExecReload=#{node[:consul][:bin]} reload
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target
  EOF
  verify false
  action [:create, :enable, :restart]
end
