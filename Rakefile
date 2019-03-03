consul_path = "./tmp/consul.zip"
consul_version = "1.4.2"
consul_url = "https://releases.hashicorp.com/consul/#{consul_version}/consul_#{consul_version}_linux_amd64.zip"

vault_path = "./tmp/vault.zip"
vault_version = "1.0.3"
vault_url = "https://releases.hashicorp.com/vault/#{vault_version}/vault_#{vault_version}_linux_amd64.zip"


task :deps do
  if ! File.exist? consul_path
    sh "curl -v #{consul_url} -o ./tmp/consul.zip"
  end
  if ! File.exist? vault_path
    sh "curl -v #{vault_url} -o ./tmp/vault.zip"
  end
end
