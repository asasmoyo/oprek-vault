user = 'consul'

apt_repository 'nginx' do
  uri 'http://nginx.org/packages/mainline/ubuntu'
  components ['nginx']
  key 'https://nginx.org/keys/nginx_signing.key'
end

package 'nginx' do
  action :upgrade
end

consul_template_zip = '/vagrant/tmp/consul-template.zip'
consul_template_dir = '/opt/consul-template'
consul_template_bin = "#{consul_template_dir}/current/consul-template"
directory consul_template_dir do
  action :create
  owner user
  group user
  mode 0775
end

execute "install consul template" do
  command "unzip #{consul_template_zip} -d #{consul_template_dir}/current"
  user user
  group user
  only_if { ! ::File.exist? consul_template_bin }
end

file '/etc/nginx/conf.d/vault.conf' do
  content <<~EOF
    upstream active_vault {
      server vault.service.consul:8200;
    }

    server {
      listen 8200;
      location / {
        proxy_pass http://active_vault;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      }
    }
  EOF
end

service 'nginx' do
  action [:restart]
end
