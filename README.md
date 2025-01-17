# local-docker-registry

# Create a directory and access it
```
 mkdir registry && cd "$_"
```

# Create subdirectories
```
mkdir certs 
mkdir auth
```

# Generate private key
```
cd certs/openssl genrsa 1024 > domain.key
chmod 400 domain.key
```

# Generate certificate 
```
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt
```

# Verify
```
ls
```
output: domain.crt domain.key

# Access auth/ directory
```
cd ../auth/
```
# Use the registry container to generate a htpasswd file
```
docker run --rm httpd:2.4 htpasswd -Bbn username password > htpasswd
```

# Verify
```
cat htpasswd
```
output: username:$2y$05$mnaMdOsL7RCjyhTwYnGSp.7OUmZyd2EYLYj0WWKGKSpcVCl9

[ req_distinguished_name ]
countryName            = "GB"
localityName           = "London"
organizationName       = "Just Me and Opensource"
organizationalUnitName = "YouTube"
commonName             = yourdomain.com
emailAddress           = "test@example.com"
# Go to /etc/hosts 
``` 
echo "127.0.0.1 yourdomain.com" >> /etc/hosts 
```
# Go back inside your registry/ directory
```
 cd ..
 pwd 
 ```
output : /Users/xxx/registry
# Start Registry container
``` 
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
  ```

# Pull busybox image
``` 
docker pull busybox 
```
# Tag the image
``` 
docker tag busybox yourdomain.com:443/busybox 
```
# Try to push the image
``` 
docker push yourdomain.com:443/busybox
 ```
The push refers to repository [yourdomain.com:443/busybox]
0314be9edf00: Preparing
no basic auth credentials
# Perform a docker login
```
docker login -u username https://yourdomain.com:443
```
Password:
Login Succeeded
# Push again
```
docker push yourdomain.com:443/busybox
```
The push refers to repository [yourdomain.com:443/busybox]
0314be9edf00: Pushed
latest: digest: sha256:186694df7e479d2b8bf075d9e1b1d7a884c6de60470006d572350573bfa6dcd2 size: 527