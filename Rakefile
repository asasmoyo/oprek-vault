consul_path = "./tmp/consul.zip"
consul_version = "1.4.2"
consul_url = "https://releases.hashicorp.com/consul/#{consul_version}/consul_#{consul_version}_linux_amd64.zip"

vault_path = "./tmp/vault.zip"
vault_version = "1.0.3"
vault_url = "https://releases.hashicorp.com/vault/#{vault_version}/vault_#{vault_version}_linux_amd64.zip"

consul_template_path = "./tmp/consul-template.zip"
consul_template_version = "0.20.0"
consul_template_url = "https://releases.hashicorp.com/consul-template/#{consul_template_version}/consul-template_#{consul_template_version}_linux_amd64.zip"

task :binaries do
  if ! File.exist? consul_path
    sh "curl -v #{consul_url} -o ./tmp/consul.zip"
  end
  if ! File.exist? vault_path
    sh "curl -v #{vault_url} -o ./tmp/vault.zip"
  end
  if ! File.exist? consul_template_path
    sh "curl -v -L #{consul_template_url} -o ./tmp/consul-template.zip"
  end
end

namespace :consul do
  nodes = {
    "10.11.12.11" => "node1",
    "10.11.12.12" => "node2",
    "10.11.12.13" => "node3",
  }
  task :bootstrap_acl do
    found = false
    leader_node = nil

    for attempt in 1..5
      leader_ip = `curl http://10.11.12.11:8500/v1/status/leader -s`.tr('"', '').split(':')[0]
      leader_node = nodes[leader_ip]
      if leader_node.nil?
        puts "failed to find leader node, got response: '#{leader_ip}'"
        sleep 3
        next
      end
      found = true
      break
    end

    output = `vagrant ssh #{leader_node} -c "/opt/consul/current/consul acl bootstrap"`
    if ! output.include? 'AccessorID:'
      abort "got invalid output:\n#{output}"
    end

    puts output
    bootstrap_file = './tmp/bootstrap'
    File.write bootstrap_file, output
  end
end
