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

file node[:vault][:config_file] do
  content <<~EOF
    listener "tcp" {
      address     = "0.0.0.0:8200"
      tls_disable = 1
    }

    storage "consul" {
      address = "127.0.0.1:8500"
      path    = "vault/"
    }

    ui = true
    api_addr = "http://#{listen_ip}:8200"
  EOF
  user node[:vault][:user]
  group node[:vault][:user]
  mode 0664
  action :create
end

systemd_unit 'vault.service' do
  content <<~EOF
    [Unit]
    Description="HashiCorp Vault - A tool for managing secrets"
    Documentation=https://www.vaultproject.io/docs/
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=#{node[:vault][:config_file]}

    [Service]
    User=#{node[:vault][:user]}
    Group=#{node[:vault][:user]}
    ProtectSystem=full
    ProtectHome=read-only
    PrivateTmp=yes
    PrivateDevices=yes
    SecureBits=keep-caps
    AmbientCapabilities=CAP_IPC_LOCK
    Capabilities=CAP_IPC_LOCK+ep
    CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
    NoNewPrivileges=yes
    ExecStart=#{node[:vault][:bin]} server -config=#{node[:vault][:config_file]}
    ExecReload=/bin/kill --signal HUP $MAINPID
    KillMode=process
    KillSignal=SIGINT
    Restart=on-failure
    RestartSec=5
    TimeoutStopSec=30
    StartLimitIntervalSec=60
    StartLimitBurst=3
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target
  EOF
  verify false
  action [:create, :enable, :restart]
end

file node[:vault][:env_file] do
  content <<~EOF
    export VAULT_ADDR=http://127.0.0.1:8200
  EOF
  user 'root'
  group 'root'
  mode 0660
end
