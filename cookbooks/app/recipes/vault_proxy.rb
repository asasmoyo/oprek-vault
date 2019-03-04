file '/etc/nginx/conf.d/vault.conf' do
  content <<~EOF
    upstream active_vault {
      server vault.service.consul:8200 max_fails=3 fail_timeout=1;
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

service 'nginx' do
  action [:restart]
end
