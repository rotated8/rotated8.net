#!/usr/bin/bash
apt-get update
apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates

# Ensure Python3
apt-get install -y build-essential python3 python3-dev

# Install Nginx, uWSGI, and Flask
apt-get install -y nginx
wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py
pip3 install uwsgi flask

# Configure Nginx
TMPFILE=`/bin/mktemp`
cat /etc/nginx/nginx.conf | sed "s/worker_processes .\+;/worker_processes auto;/" > $TMPFILE

# Create Nginx Site
cat > $TMPFILE <<HereDoc
limit_req_zone \$binary_remote_addr zone=clients:1m rate=75r/s;
server {
    listen 80;
    server_name rotated8.net;
    client_max_body_size 1M;
    limit_req zone=clients burst=500 nodelay;
    location / { try_files $uri @rotated8-dot-net; }
    location @rotated8-dot-net {
        include uwsgi_params;
        uwsgi_pass unix:/tmp/uwsgi.sock;
    }
}
HereDoc

# Install the site, and disable the default site.
install -o root -g root -m 644 $TMPFILE /etc/nginx/sites-available/rotated8.site
rm $TMPFILE
link /etc/nginx/sites-available/rotated8.site /etc/nginx/sites-enabled/rotated8.site
unlink /etc/nginx/sites-enabled/default

# Add user 'rotated8'
useradd rotated8
#passwd rotated8

# Clone app
apt-get install -y git
mkdir -p /var/www/rotated8.net
chown rotated8: /var/www/rotated8.net
cd /var/www/
sudo -u rotated8 git clone https://github.com/rotated8/rotated8.net /var/www/rotated8.net

# Copy the service configuration.
cp /var/www/rotated8.net/rotated8-dot-net.conf /etc/init
service rotated8-dot-net start

# Restart Nginx
service nginx restart
