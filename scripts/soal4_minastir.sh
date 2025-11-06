echo "configure local dns resolver"
cat > /etc/bind/named.conf.local << EOF
zone "k17.com" {
    type forward;
    forwarders { 10.72.2.3; }; // Erendis IP
};
EOF

echo "bind9 service restart" 
service named restart

echo "done"