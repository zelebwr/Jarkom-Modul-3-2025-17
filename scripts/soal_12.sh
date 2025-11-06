apt udpate
apt install apache2-utils -y
htttpasswd -c -B /etc/nginx/.htpasswd noldor
silvan

chown root:root /etc/nginx/.htpasswd
Chmod 640 /etc/nginx/.htpasswd

Nano /etc/nginx/sites-available/default
// di dalam server { }
        auth_basic "Restricted";                                        //tambahkan ini
        auth_basic_user_file /etc/nginx/.htpasswd;          //tambahkan ini

nginx -t
service nginx restart

Tes Akses
curl -i http://elros.k17.com/api/airing
curl -i -u noldor:silvan http://elros.k17.com/api/airing

