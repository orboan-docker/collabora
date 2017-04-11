#!/bin/sh

hostname=col.iaw.io

DOMAIN=nc.iaw.io
DOMAIN_RE=$(echo "$DOMAIN" | sed 's/\./\\\\./g')

# Fix lool resolv.conf problem (wizdude)
rm /opt/lool/systemplate/etc/resolv.conf
ln -s /etc/resolv.conf /opt/lool/systemplate/etc/resolv.conf

# Replace trusted host and set admin username and password
perl -pi -e "s/localhost<\/host>/${DOMAIN_RE}<\/host>/g" /etc/loolwsd/loolwsd.xml
perl -pi -e "s/<username desc=\"The username of the admin console. Must be set.\"><\/username>/<username desc=\"The username of the admin console. Must be set.\">${USERNAME}<\/username>/" /etc/loolwsd/loolwsd.xml
perl -pi -e "s/<password desc=\"The password of the admin console. Must be set.\"><\/password>/<password desc=\"The password of the admin console. Must be set.\">${PASSWORD}<\/password>/g" /etc/loolwsd/loolwsd.xml

cp -r /loolwsd/* /etc/loolwsd/

# Start loolwsd
su -c "/usr/bin/loolwsd --version --o:sys_template_path=/opt/lool/systemplate --o:lo_template_path=/opt/collaboraoffice5.1 --o:child_root_path=/opt/lool/child-roots --o:file_server_root_path=/usr/share/loolwsd" -s /bin/bash lool

