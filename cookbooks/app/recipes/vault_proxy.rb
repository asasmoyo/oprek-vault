file "#{node[:consul_template][:template_dir]}/vault.conf.ctmpl" do
  content <<~EOF
    upstream active_vault {
      {{ range service "vault" }}
      server {{ .Address }}:{{ .Port }} max_fails=3 fail_timeout=1;
      {{ end }}
    }

    server {
      listen 8200;
      resolver 127.0.0.1:53;
      location / {
        proxy_pass http://active_vault;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      }
    }
  EOF
end

file "#{node[:consul_template][:template_dir]}/app_api.env.ctmpl" do
  content <<~EOF
    {
      {{ with secret "database/creds/app-api-writer" }}
        "username": "{{ .Data.username }}",
        "password": "{{ .Data.password }}"
      {{ end }}
    }
  EOF
end

file "#{node[:consul_template][:config_dir]}/vault.hcl" do
  content <<~EOF
    vault {
      address = "http://vault.service.consul:8200"
      token = "s.HjigB8lxt9pIBG3eJQmN08Sz"
      unwrap_token = false
      renew_token = false
      log_level = "debug"
      ssl {
        enabled = false
      }
    }

    template {
      source = "#{node[:consul_template][:template_dir]}/vault.conf.ctmpl"
      destination = "/etc/nginx/conf.d/vault.conf"
      command = "sudo systemctl restart nginx"
      command_timeout = "5s"
      perms = 0664
    }

    template {
      source = "#{node[:consul_template][:template_dir]}/app_api.env.ctmpl"
      destination = "/home/vagrant/app_api.env"
      perms = 0660
    }
  EOF
end

service 'nginx' do
  action [:restart]
  # can fail when no unsealed vault
  ignore_failure true
end
