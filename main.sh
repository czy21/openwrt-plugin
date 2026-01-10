#!/bin/bash

shopt -s expand_aliases

if [ -n "$(type -p gfind)" ];then
  alias find='gfind'
fi

if [ -n "$(type -p gsed)" ];then
  alias sed='gsed'
fi

type find
type sed

cd $(cd "$(dirname "$0")"; pwd)

branch=$(git branch --show-current)

function cp_pkg_var(){
  keys="PKG_VERSION PKG_HASH PKG_MIRROR_HASH"
  pkg_name=$(basename $(dirname $1))
  source_makefile=$1
  target_makefile=$2

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

function sparse_checkout_main() {
  [ "$branch" = "main" ] && return
  
  source_dir=feeds/czy21/openwrt-plugin
  source_packages=
  source_packages+="package/net/acme-sync "
  source_packages+="package/net/adguardhome "
  source_packages+="package/net/ddns-scripts-aliyun "
  source_packages+="package/net/dnsproxy "
  source_packages+="package/net/openvpn-auth "

  source_checkout=
  source_checkout+=$source_packages
  sparse_checkout $source_dir "https://github.com/czy21/openwrt-plugin" "$source_checkout" $branch
  for t in $source_packages;do
    mkdir -p $t && rsync -av --delete $source_dir/$t/ $t/
  done
}

function sparse_checkout_lede() {

  source_luci_dir=feeds/coolsnowwolf/luci
  source_luci_pkg="applications/luci-app-socat applications/luci-app-nfs"
  sparse_checkout $source_luci_dir "https://github.com/coolsnowwolf/luci" "$source_luci_pkg"

  for t in $source_luci_pkg;do
    pkg=luci/$(basename $t)
    mkdir -p $pkg && rsync -av --delete $source_luci_dir/$t/ $pkg/
  done

}

function sparse_checkout_immortalwrt() {

  source_packages_dir=feeds/immortalwrt/packages
  source_packages_pkg=
  if [ "$branch" != "main" ];then
    source_packages_pkg+="net/adguardhome "
  fi
  source_checkout=
  source_checkout+=$source_packages_pkg

  if [ -z "${source_checkout}" ];then
    return
  fi

  sparse_checkout $source_packages_dir "https://github.com/immortalwrt/packages" "$source_checkout" $([ "$branch" = "main" ] && echo master || echo $branch)

  for t in $source_packages_pkg;do
    cp_pkg_var $source_packages_dir/$t/Makefile package/$t/Makefile
  done
  
}

function sparse_checkout_official() {

  source_packages_dir=feeds/openwrt/packages
  source_packages_pkg=
  source_packages_pkg+="net/dnsproxy "

  if [ "$branch" = "main" ];then
    source_packages_pkg+="net/adguardhome "
  fi

  source_checkout=
  source_checkout+=$source_packages_pkg

  if [ "$branch" = "main" ];then
    source_checkout+="net/ddns-scripts/files/usr/lib/ddns/update_aliyun_com.sh "
  fi

  sparse_checkout $source_packages_dir "https://github.com/openwrt/packages" "$source_packages_pkg" $([ "$branch" = "main" ] && echo master || echo $branch)

  if [ "$branch" = "main" ];then
    cp -rv $source_packages_dir/net/ddns-scripts/files/usr/lib/ddns/update_aliyun_com.sh package/net/ddns-scripts-aliyun/files/
  fi

  for t in $source_packages_pkg;do
    cp_pkg_var $source_packages_dir/$t/Makefile package/$t/Makefile
  done

}

if [ "$1" == "update" ];then

  sparse_checkout_main
  sparse_checkout_lede
  sparse_checkout_immortalwrt
  sparse_checkout_official

  find -name 'Makefile' -type f -not -path './feeds/*' -exec sed -i "s|include ../../luci.mk|include $\(TOPDIR\)/feeds/luci/luci.mk|g" {} \;

  find -name 'Makefile' -type f -not -path './feeds/*' -exec sed -i "s|include ../../packages/|include $\(TOPDIR\)/feeds/packages/|g" {} \;

  for s in $(find -name 'zh-cn' -type d -not -path './feeds/*'); do
    t=$(dirname $s)/zh_Hans
    mv -v $s $t
  done
fi
