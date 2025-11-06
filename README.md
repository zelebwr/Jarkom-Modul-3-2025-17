# Komunikasi Data dan Jaringan Komputer — Modul 3

## 11. Pertahanan Numenor
**Goal**: Melakukan simulasi pengujian ketahanan sistem (load testing) menggunakan **Apache Benchmark (ab)** terhadap layanan API sederhana yang dijalankan menggunakan **Flask**, dengan dukungan **HAProxy** sebagai load balancer.

### 11.1 Konfigurasi

Pada node *client*, install **ApacheBench** dengan menjalankan perintah berikut:
```
apt update
apt install apache2-utils
```

Lalu, ubah konfigurasi file `/etc/hosts` dan tambahkan domain `elros.k17.com` mengarah ke IP server **Elros**
```
nano /etc/hosts
```
Tambahkan konfigurasi berikut:
```
10.72.1.7    elros.k17.com
```

Pada node **Elros**, instal dependensi dengan perintah berikut:
```
apt udpate
apt install python3 pyhton3-flask python3-pip -y
```
Lalu, buat program pada **Elros** untuk simulasi kerja `/api/airing` 

```
nano elros_app.py
```

Buatlah program seperti berikut:
```
from flask import Flask, jsonify
import time, random
app = Flask(__name__)

@app.route('/api/airing/')
def airing():
    t = random.uniform(0.01, 0.1)
    time.sleep(t)
    return jsonify({"status":"ok","delay":t})

if __name__=='__main__':
    app.run(host='10.72.1.7', port=80)

```
Jangan lupa untuk install dependensi `flask` sebelum menjalankan program

```
pip3 install flask
```

Lalu, program bisa dijalankan
```
python3 elros_app.py
```

Pada node **Durin**, install dependensi yang diperlukan dan atur konfigurasi

```
apt update
apt install haproxy -y
nano /etc/haproxy/haproxy.cfg
```
Tambahkan konfigurasi berikut:
```
global
    daemon
    maxconn 20000

defaults
    mode http
    timeout connect 5s
    timeout client  50s
    timeout server  50s
    option httplog

frontend http-in
    bind *:80
    default_backend elros-back

backend elros-back
    balance roundrobin
    server worker1 10.72.1.7:80 check
```
Lalu, *restart* `haproxy` untuk menerapkan perubahan pada konfigurasi.
```
service haproxy restart
```
### 11.2 Simulasi Serangan

Kembali pada node *client*, simulasikan serangan menggunakan **ApacehBench** dengan perintah berikut:
```
echo “serangan awal” >> catatan.log && ab -n 100 -c 10 http://elros.k17.com/api/airing/ >> catatan.log
echo “serangan penuh” >> catatan.log && ab -n 2000 -c 100 http://elros.k17.com/api/airing/ >> catatan.log
```

## 12. PHP Web Server

**Goal**: Menjalankan PHP 8.4-FPM
dan mebatasi akses hanya melalui nama domain, bukan alamat IP

### 12.1 Konfigurasi

Pada tiap node *worker*, instal dependensi berikut:
```
apt update
apt install nginx php8.4-fpm -y
service nginx start
service php8.4-fpm
nano /var/www/html/index.php
```
Tambahkan baris berikut pada file:
```
<?php
echo "<h1>Welcome to " . gethostname() . "</h1>";
?>
```
Lalu pada file `/etc/nginx/sites-available/default`, tambahkan juga konfigurasi nginx berikut:
```
server {
    listen 80;
    server_name galadriel.k17.com; #sesuaikan utk tiap node

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    if ($host ~* "^\d+\.\d+\.\d+\.\d+$") {
        return 403;
    }
}
```
Terapkan perubahan konfigurasi dengan perintah berikut:
```
nginx -t
service nginx restart
```

tambahkan domain pada file `/etc/hosts` sebagai berikut:
```
10.72.4.7    galadriel.k17.com
10.72.4.6    celeborn.k17.com
10.72.4.5    oropher.k17.com
```
### 12.2 Uji Konfigurasi

Ketika kita menjalankan perintah `curl http://oropher.k17.com`. Akan didapatkan respon sebagai berikut:

![alt text](<Cuplikan layar 2025-11-06 111831.png>)

dan untuk perintah `curl http://10.73.4.5` akan didapatkan respon sebagai berikut:

![alt text](<Cuplikan layar 2025-11-06 111808.png>)

## 13. Nginx Custom Listen Port

**Goal**: Atur agar **Galadriel** mendengarkan di port 8004, **Celeborn** di 8005, dan **Oropher** di 8006.

### 13.1 Konfigurasi

Pada tiap node, tambahkan konfigurasi berikut pada file `/etc/nginx/sites-avaiable/default`
```
server {
    listen 8004; # Sesuaikan port berikut sesuai soal
    # konfigurasi lain
}
```
Terapkan perubahan pada konfigurasi
```
nginx -t
service nginx restart
```

### 13.2 Uji Konfigurasi
Uji konfigurasi dengan melakuakn perintah `curl http://oropher.k17.com` dan respon yang didapatkan seharusnya server tidak terkoneksi.

Gunakan perintah `curl http://oropher.k17.com:8006` untuk mendapatkan *return* berupa isi dari `index.php`.

## 14. Basic Authentication

**Goal**: Terapkan *basic authentication* pada konfigurasi nginx

### 14.1 Konfigurasi

Install `apache2-utils` untuk menggunakan `htpasswd` yang akan kita gunakan dalam konfigurasi `nginx`
```
apt update
apt install apache2-utils -y
```

Lalu, buat file autentikasi dengan perintah berikut untuk username sebagai `noldor`:
```
htpasswd -c -B /etc/nginx/.htpasswd noldor
```
Gunakan password `silvan` seperti instruksi pada soal.

Kemudian, ubah akese file dengan perintah berikut:
```
chown root:root /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd
```

Pada konfigurasi nginx, tambahkan pengaturan berikut di dalam `server { }` yang ada:
```
auth_basic "Restricted";
auth_basic_user_file /etc/nginx/.htpasswd;
```
Terapkan perubahan pada konfigurasi:
```
nginx -t
service nginx restart
```

### 14.2 Uji Akses
Jika kita menjalankan perintah ```curl http://elros.k17.com/api/airing```, akan didapatkan *Unauthorized prompt* seperti berikut:

Lakukan juga uji dengan kredensial yang sudah ditentukan menggunakan perintah berikut:
```
curl -u noldor:silvan http://elros.k17.com/api/airing
```
Jika konfigurasi sudah berjalan dengan benar, maka akan didapatkan *prompt* seperti ini: