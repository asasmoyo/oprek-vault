postgresql_server_install 'install postgresql' do
  action :install
  version '11'
end

postgresql_server_install 'init postgresql cluster' do
  action :create
  password node[:app][:database][:postgres_password]
end

service 'postgresql' do
  supports restart: true
  action [:enable, :start]
end

postgresql_server_conf 'postgresql conf' do
  version '11'
  additional_config ({
    'listen_addresses' => '0.0.0.0',
  })
  notifies :restart, 'service[postgresql]', :immediate
end

postgresql_database node[:app][:database][:name] do
  owner 'postgres'
  locale 'en_US.utf8'
  template 'template0'
end

postgresql_user node[:app][:database][:username] do
  login true
  encrypted_password node[:app][:database][:password]
end

postgresql_access "db access for postgres" do
  access_type 'host'
  access_user 'postgres'
  access_addr '10.11.12.0/24'
  access_method 'md5'
  notifies :restart, 'service[postgresql]', :immediate
end
