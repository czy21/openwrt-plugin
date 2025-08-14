#!/bin/bash

cd $(cd "$(dirname "$0")"; pwd)

branch=$(git branch --show-current)

function cp_pkg(){
  pkg_path=$1
  pkg_name=`basename $1`
  cp -rv package/${pkg_name}/files/ ../packages/${pkg_path}
  [ -f "package/${pkg_name}/Makefile.override" ] && cp -rv package/${pkg_name}/Makefile.override ../packages/${pkg_path}/Makefile    
}

function cp_pkg_var(){
  keys="PKG_VERSION PKG_RELEASE PKG_HASH PKG_MIRROR_HASH"
  pkg_name=$(basename $(dirname $1))
  source_makefile=$1
  target_makefile=package/${pkg_name}/Makefile

  if [ "${pkg_name}" == "adguardhome" ];then
    keys+=" FRONTEND_HASH"
  fi
  
  if [ -f "$target_makefile" ];then
    for k in $keys;do
      v=$(sed -n "s|^$k:=\(.*\)|\1|p" $source_makefile)

      if [[ -z "$v" ]] && [[ "$k" == "FRONTEND_HASH" ]]; then
        v=$(sed -n "s|^[[:space:]]*HASH:=\(.*\)|\1|p" $source_makefile)
      fi

      sed -i "s|^$k:=.*|$k:=$v|" $target_makefile
    done  
  else
    echo "$target_makefile not found"
  fi
}

function sparse_checkout(){
  feed_dir=$1
  feed_url=$2
  feed_pkg=$3
  feed_branch=$4
  feed_branch=${feed_branch:-master}
  rm -rf $feed_dir && mkdir -p $feed_dir
  (
   cd $feed_dir;
   git init
   git remote add origin $feed_url
   git config core.sparsecheckout true
   git sparse-checkout set $feed_pkg
   git pull origin $feed_branch
  )
}

function sparse_checkout_lede(){

  lede_dir=feeds/coolsnowwolf/lede
  lede_pkg="package/lean/ddns-scripts_aliyun/update_aliyun_com.sh"
  sparse_checkout $lede_dir "https://github.com/coolsnowwolf/lede" "$lede_pkg"
  cp -rv $lede_dir/package/lean/ddns-scripts_aliyun/update_aliyun_com.sh package/ddns-scripts-aliyun/files/

  
  lede_luci_dir=feeds/coolsnowwolf/luci
  lede_luci_pkg="applications/luci-app-socat applications/luci-app-nfs"
  sparse_checkout $lede_luci_dir "https://github.com/coolsnowwolf/luci" "$lede_luci_pkg"

  for t in $lede_luci_pkg;do
    rm -rf luci/$(basename $t)
    cp -rv $lede_luci_dir/$t luci/
  done

}

function sparse_checkout_immortalwrt(){

  immortalwrt_packages_dir=feeds/immortalwrt/packages
  immortalwrt_packages_pkg="net/adguardhome"
  sparse_checkout $immortalwrt_packages_dir "https://github.com/immortalwrt/packages" "$immortalwrt_packages_pkg" $([ "$branch" == "main" ] && echo master || echo $branch)

  for t in $immortalwrt_packages_pkg;do
    cp_pkg_var $immortalwrt_packages_dir/$t/Makefile
  done
  
}

function sparse_checkout_official(){

  official_packages_dir=feeds/openwrt/packages
  official_packages_pkg="net/dnsproxy"
  sparse_checkout $official_packages_dir "https://github.com/openwrt/packages" "$official_packages_pkg" $([ "$branch" == "main" ] && echo master || echo $branch)

  for t in $official_packages_pkg;do
    cp_pkg_var $official_packages_dir/$t/Makefile
  done

}

################################################
if [ "$1" == "update" ];then

  sparse_checkout_lede
  sparse_checkout_immortalwrt
  sparse_checkout_official

  find -name 'Makefile' -type f -exec sed -i "s|include ../../luci.mk|include $\(TOPDIR\)/feeds/luci/luci.mk|g" {} \;

  find -name 'Makefile' -type f -exec sed -i "s|include ../../packages/|include $\(TOPDIR\)/feeds/packages/|g" {} \;

  for i in $(find -name 'zh-cn' -type d); do
    zh_Hans_dir=$(dirname $i)/zh_Hans
    mkdir -p ${zh_Hans_dir}
    cp -rv $i/* ${zh_Hans_dir}
    rm -rf $i
  done
fi

if [ "$1" == "check" ];then
  echo "check"
fi
