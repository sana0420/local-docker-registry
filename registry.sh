mkdir registry && cd "$_"
mkdir certs 
mkdir auth
cd certs/openssl genrsa 1024 > domain.key
chmod 400 domain.key
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt
ls

cd ../auth/

docker run --rm httpd:2.4 htpasswd -Bbn username password > htpasswd

cat htpasswd
echo "127.0.0.1 docker.registry.com" >> /etc/hosts 

 cd ..
 pwd
docker run -d \
  --restart=always \
  --name registry \
  -v `pwd`/auth:/auth \
  -v `pwd`/certs:/certs \
  -v `pwd`/certs:/certs \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 443:443 \
  registry:2 
docker pull busybox 
 
docker tag busybox docker.registry.com:443/busybox 

docker push docker.registry.com:443/busybox

docker login -u username https://docker.registry.com:443
docker push docker.registry.com:443/busybox
