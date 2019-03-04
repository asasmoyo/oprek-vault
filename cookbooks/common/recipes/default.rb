package ['htop', 'nload', 'tree', 'unzip', 'dnsmasq']

file '/etc/dnsmasq.conf' do
  content <<~EOF
    port=53
    domain-needed
    bogus-priv
    strict-order
    expand-hosts
    listen-address=127.0.0.1
    server=/consul/127.0.0.1#8600
  EOF
end

file '/etc/resolv.conf' do
  content <<~EOF
    nameserver 127.0.0.1
    nameserver 8.8.8.8
  EOF
end

systemd_unit 'systemd-resolved' do
  action [:stop, :disable]
end

systemd_unit 'dnsmasq' do
  action [:enable, :restart]
end
