echo "install bind9"
apt-get update
apt-get install bind9 -y

echo "configure bind9"
cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";
    forwarders {
        10.72.2.3;
        10.72.2.4;
        192.168.122.1;
    };
    forward only;
    allow-query { any; };
    dnssec-validation no;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF

echo "bind9 service restart" 
service named restart

echo "done"