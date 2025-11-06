echo "install isc dhcp relay"
apt-get update
apt-get install isc-dhcp-relay -y

echo "configure dhcp relay"
cat > /etc/default/isc-dhcp-relay << EOF
SERVERS="10.72.3.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""
EOF

echo "activate forwarding"
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
EOF
sysctl -p

echo "restart dhcp relay"
service isc-dhcp-relay restart

echo "done"
