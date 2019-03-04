apt_repository 'nginx' do
  uri 'http://nginx.org/packages/mainline/ubuntu'
  components ['nginx']
  key 'https://nginx.org/keys/nginx_signing.key'
end

package 'nginx' do
  action :install
end
