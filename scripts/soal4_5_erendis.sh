echo "install bind9"
apt-get update
apt-get install bind9 -y

echo "configure dns master zones (forward and reverse)"
cat > /etc/bind/named.conf.local << EOF
zone "k17.com" {
    type master;
    file "/etc/bind/k17.com.db"; // Zone file location
    allow-transfer { 10.72.2.4; };   // Allow Amdir (Slave)
};

zone "2.72.10.in-addr.arpa" {
    type master;
    file "/etc/bind/10.72.2.db";   // Reverse zone file location
    allow-transfer { 10.72.2.4; };   // Allow Amdir (Slave) 
};
EOF

echo "configure the forward zone file (k17.com.db)"
cat > /etc/bind/k17.com.db << EOF
\$TTL    604800
@       IN      SOA     ns1.k17.com. root.k17.com. (
                   2025110101         ; Serial
                       604800         ; Refresh
                        86400         ; Retry
                      2419200         ; Expire
                       604800 )       ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.k17.com.
@       IN      NS      ns2.k17.com.
 
; Name Server IPs
ns1     IN      A       10.72.2.3       ; Erendis
ns2     IN      A       10.72.2.4       ; Amdir

; Alias for the main domain
www     IN      CNAME   k17.com.

; A Records for nodes (Soal 4)
palantir    IN      A       10.72.3.3
elros       IN      A       10.72.1.7
pharazon    IN      A       10.72.4.2 
elendil     IN      A       10.72.1.2
isildur     IN      A       10.72.1.3
anarion     IN      A       10.72.1.4
galadriel   IN      A       10.72.4.7
celeborn    IN      A       10.72.4.6
oropher     IN      A       10.72.4.5

; (Secret Messages - TXT Records - Soal 5)
elros       IN      TXT     "Cincin Sauron"
pharazon    IN      TXT     "Aliansi Terakhir"
EOF

echo "configure the reverse zone file (10.72.2.db)"
cat > /etc/bind/10.72.2.db << EOF
\$TTL    604800
@       IN      SOA     k17.com. root.k17.com. (
                   2025110101         ; Serial
                       604800         ; Refresh
                        86400         ; Retry
                      2419200         ; Expire
                       604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.k17.com.
@       IN      NS      ns2.k17.com.

; PTR Records for Erendis (ns1) and Amdir (ns2)
3       IN      PTR     ns1.k17.com. ; 10.72.2.3
4       IN      PTR     ns2.k17.com. ; 10.72.2.4
EOF

echo "checking configuration"
named-checkconf
named-checkzone k17.com /etc/bind/k17.com.db
named-checkzone 2.72.10.in-addr.arpa /etc/bind/10.72.2.db

echo "bind9 service restart"
service named restart

echo "done"