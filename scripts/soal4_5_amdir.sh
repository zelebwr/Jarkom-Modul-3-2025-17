echo "install bind9" 
apt-get update
apt-get install bind9 -y

echo "configure dns slave zones"
cat > /etc/bind/named.conf.local << EOF
zone "k17.com" {
    type slave;
    masters { 10.72.2.3; }; // Erendis IP
    file "/var/lib/bind/k17.com.db";
};

zone "2.72.10.in-addr.arpa" {
    type slave;
    masters { 10.72.2.3; }; // Erendis IP
    file "/var/lib/bind/10.72.2.db";
};
EOF

echo "bind9 service restart" 
service named restart

echo "done"