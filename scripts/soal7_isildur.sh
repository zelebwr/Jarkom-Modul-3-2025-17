echo "installation"
apt-get update
apt-get install -y lsb-release apt-transport-https ca-certificates wget git nginx

echo "add sury gpg key"
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update

echo "installation php8.4 and extensions"
apt install php8.4-mbstring php8.4-xml php8.4-cli php8.4-common php8.4-intl php8.4-opcache php8.4-readline php8.4-mysql php8.4-fpm php8.4-curl unzip wget -y

echo "check php installation version"
php --version

echo "install nginx" 
apt-get install nginx -y

echo "install composer"
wget https://getcomposer.org/download/latest-stable/composer.phar
mv composer.phar /usr/bin/composer
chmod +x /usr/bin/composer

echo "check composer installation version"
composer -V

echo "laravel project setup"
cd /var/www/
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git

echo "installation laravel dependencies"
cd /var/www/laravel-simple-rest-api
composer update
composer install

echo "make the database configuration changes in .env file"
cat > /var/www/laravel-simple-rest-api/.env << EOF
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://isildur.k17.com:8002

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=10.72.3.4
DB_PORT=3306
DB_DATABASE=dbkelompokyyy
DB_USERNAME=kelompokyyy
DB_PASSWORD=passwordyyy
EOF

php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
php artisan key:generate

cat > /etc/nginx/sites-available/isildur.k17.com << 'EOF'
server {
    # isildur listens on port 8002
    listen 8002;
    server_name isildur.k17.com;

    root /var/www/laravel-simple-rest-api/public;
    index index.php;

    # Block access via IP address 
    if ($host != "isildur.k17.com") {
        return 403;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/isildur.k17.com /etc/nginx/sites-enabled/
chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage
service nginx restart
service php8.4-fpm restart

echo "done"