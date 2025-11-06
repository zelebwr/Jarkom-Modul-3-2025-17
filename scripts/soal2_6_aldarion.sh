echo "install isc dhcp server"
apt-get update
apt-get install isc-dhcp-server -y

echo "configure dhcp server listen eth0"
cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth0"
EOF

echo "main configuration dhcp"
cat > /etc/dhcp/dhcpd.conf << EOF
option domain-name-servers 10.72.5.2;
subnet 10.72.1.0 netmask 255.255.255.0{
        option routers 10.72.1.1;
        option broadcast-address 10.72.1.255;
        range 10.72.1.6 10.72.1.34;
        range 10.72.1.68 10.72.1.94;
        default-lease-time 18000;
        max-lease-time 36000;
}

subnet 10.72.2.0 netmask 255.255.255.0 {
        option routers 10.72.2.1;
        option broadcast-address 10.72.2.255;
}

subnet 10.72.3.0 netmask 255.255.255.0 {
        option routers 10.72.3.1;
        option broadcast-address 10.72.3.255;
}

subnet 10.72.4.0 netmask 255.255.255.0 {
        option routers 10.72.4.1;
        option broadcast-address 10.72.4.255;
        range 10.72.4.35 10.72.4.67;
        range 10.72.4.96 10.72.4.121;
        default-lease-time 600;
        max-lease-time 36000;
}

subnet 10.72.5.0 netmask 255.255.255.0 {
        option routers 10.72.5.1;
        option broadcast-address 10.72.5.255;
}

host Khamul {
        hardware ethernet 02:42:fb:fc:e1:00;
        fixed-address 10.72.2.95;
}
EOF

echo "restart dhcp server"
service isc-dhcp-server restart

echo "done"
