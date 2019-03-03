user = "vault"

dir = "/opt/vault"
vault_zip = "/vagrant/tmp/vault.zip"
vault_bin = "#{dir}/current/vault"
config_file = "#{dir}/config.hcl"

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

execute "install vault" do
  command "unzip #{vault_zip} -d #{dir}/current"
  user user
  group user
  only_if { ! ::File.exist? vault_bin }
end

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
  user user
  group user
  mode 0775
  action :create
end

systemd_unit 'vault.service' do
  content <<~EOF
    [Unit]
    Description="HashiCorp Vault - A tool for managing secrets"
    Documentation=https://www.vaultproject.io/docs/
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=#{config_file}

    [Service]
    User=#{user}
    Group=#{user}
    ProtectSystem=full
    ProtectHome=read-only
    PrivateTmp=yes
    PrivateDevices=yes
    SecureBits=keep-caps
    AmbientCapabilities=CAP_IPC_LOCK
    Capabilities=CAP_IPC_LOCK+ep
    CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
    NoNewPrivileges=yes
    ExecStart=#{vault_bin} server -config=#{config_file}
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

  action [:create, :enable, :restart]
end
