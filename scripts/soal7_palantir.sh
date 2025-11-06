apt update
apt install mariadb-server -y
service mariadb start

cat > /etc/mysql/my.cnf << EOF
[mysqld]
skip-networking=0
skip-bind-address
EOF

# mariadb

# CREATE USER 'kelompokyyy'@'%' IDENTIFIED BY 'passwordyyy';
# CREATE USER 'kelompokyyy'@'localhost' IDENTIFIED BY 'passwordyyy';
# CREATE DATABASE dbkelompokyyy;
# GRANT ALL PRIVILEGES ON *.* TO 'kelompokyyy'@'%';
# GRANT ALL PRIVILEGES ON *.* TO 'kelompokyyy'@'localhost';
# FLUSH PRIVILEGES;

apt install mariadb-client -y
# mariadb --host=10.40.2.5 --port=3306 --user=kelompokyyy --password