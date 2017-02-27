#!/bin/sh
if [ -z "$HOSTNAME" ]; then
hostname=localhost
else 
hostname=$HOSTNAME
fi

DOMAIN_RE=$(echo "$DOMAIN" | sed 's/\./\\\\./g')

# Fix lool resolv.conf problem (wizdude)
rm /opt/lool/systemplate/etc/resolv.conf
ln -s /etc/resolv.conf /opt/lool/systemplate/etc/resolv.conf

# Generate new SSL certificate instead of using the default
mkdir -p /opt/ssl/
cd /opt/ssl/
mkdir -p certs/ca
openssl genrsa -out certs/ca/root.key.pem 2048
openssl req -x509 -new -nodes -key certs/ca/root.key.pem -days 9131 -out certs/ca/root.crt.pem -subj "/C=CA/ST=BCN/L=Barcelona/O=Dummy Authority/CN=Dummy Authority"
mkdir -p certs/{servers,tmp}
mkdir -p "certs/servers/${hostname}"
openssl genrsa -out "certs/servers/${hostname}/privkey.pem" 2048 -key "certs/servers/${hostname}/privkey.pem"
openssl req -key "certs/servers/${hostname}/privkey.pem" -new -sha256 -out "certs/tmp/${hostname}.csr.pem" -subj "/C=CA/ST=BCN/L=Barcelona/O=Dummy Authority/CN=${hostname}"
openssl x509 -req -in certs/tmp/${hostname}.csr.pem -CA certs/ca/root.crt.pem -CAkey certs/ca/root.key.pem -CAcreateserial -out certs/servers/${hostname}/cert.pem -days 9131
mv certs/servers/${hostname}/privkey.pem /etc/loolwsd/key.pem
mv certs/servers/${hostname}/cert.pem /etc/loolwsd/cert.pem
mv certs/ca/root.crt.pem /etc/loolwsd/ca-chain.cert.pem

# Replace trusted host and set admin username and password
perl -pi -e "s/localhost<\/host>/${DOMAIN_RE}<\/host>/g" /etc/loolwsd/loolwsd.xml
perl -pi -e "s/<username desc=\"The username of the admin console. Must be set.\"><\/username>/<username desc=\"The username of the admin console. Must be set.\">${USERNAME}<\/username>/" /etc/loolwsd/loolwsd.xml
perl -pi -e "s/<password desc=\"The password of the admin console. Must be set.\"><\/password>/<password desc=\"The password of the admin console. Must be set.\">${PASSWORD}<\/password>/g" /etc/loolwsd/loolwsd.xml

# Start loolwsd
su -c "/usr/bin/loolwsd --version --o:sys_template_path=/opt/lool/systemplate --o:lo_template_path=/opt/collaboraoffice5.1 --o:child_root_path=/opt/lool/child-roots --o:file_server_root_path=/usr/share/loolwsd" -s /bin/bash lool

