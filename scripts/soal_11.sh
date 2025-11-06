Node Client
apt update
apt install apache2-utils
nano /etc/hosts
10.72.1.7	elros.k18.com

Elros
apt update
apt install python3 python3-flask -y
nano elros_app.py
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
python3 elros_app.py


Durin
apt update
apt install haproxy -y
nano /etc/haproxy/haproxy.cfg
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

service haproxy restart

Node Client
echo “serangan awal” >> catatan.log && ab -n 100 -c 10 http://elros.k17.com/api/airing/ >> catatan.log
echo “serangan awal” >> catatan.log && ab -n 2000 -c 100 http://elros.k17.com/api/airing/ >> catatan.log