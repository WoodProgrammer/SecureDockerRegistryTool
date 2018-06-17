#!/bin/bash
echo "DOMAIN NAME"
read domain

echo "SSL Signing and creating"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

echo "Nginx Key : /etc/nginx/ssl/nginx.key"
echo "Nginx Crt : /etc/nginx/ssl/nginx.crt"


echo "Initializing to Swarm"

docker swarm init 

echo "Registry Username"
read username

echo "Registry Password"
read password

docker run --entrypoint htpasswd registry:2 -Bbn $username $password > /etc/nginx/ssl/auth/htpasswd

echo "Domain Name Added and config file copying to the /etc/nginx/conf.d"

sed -i -e 's/DOMANIN/$domain/g' registry.conf
cp registry.conf /etc/nginx/conf.d/.

 

echo "Registry Service Created ! "

docker run -d -p 5000:5000 --restart=always --name registry \
  -v /etc/nginx/conf.d/:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/registry.password \
  registry:2



