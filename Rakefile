consul_version = "1.4.2"
consul_url = "https://releases.hashicorp.com/consul/#{consul_version}/consul_#{consul_version}_linux_amd64.zip"

task :deps do
  sh "curl -v #{consul_url} -o ./tmp/consul.zip"
end
