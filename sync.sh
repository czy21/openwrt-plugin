#!/bin/bash
cd $(cd "$(dirname "$0")"; pwd)

function cp_pkg(){
  pkg_path=$1
  pkg_name=`basename $1`
  cp -rv package/${pkg_name}/files/ ../packages/${pkg_path}
  [ -f "package/${pkg_name}/Makefile.override" ] && cp -rv package/${pkg_name}/Makefile.override ../packages/${pkg_path}/Makefile    
}

for i in "net/dnsproxy" "net/adguardhome" "libs/openldap"; do
  cp_pkg $i
done

# openldap
sed -i -e 's|$(INSTALL_BIN) ./files/ldap.init $(1)/etc/init.d/ldap|$(INSTALL_BIN) ./files/openldap.init $(1)/etc/init.d/openldap|' ../packages/libs/openldap/Makefile