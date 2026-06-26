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
  keys="PKG_VERSION PKG_HASH PKG_MIRROR_HASH FRONTEND_HASH"
  pkg_name=$(basename $(dirname $1))
  source_makefile=$1
  target_makefile=$2

  source_pkg_version=`sed -n "s|^PKG_VERSION:=\(.*\)|\1|p" $source_makefile`
  target_pkg_version=`sed -n "s|^PKG_VERSION:=\(.*\)|\1|p" $target_makefile`

  # 如果版本号为空或者源版本小于目标版本，则 return
  [[ -z "$source_pkg_version" || -z "$target_pkg_version" ]] || [ "$(printf '%s\n%s' "$target_pkg_version" "$source_pkg_version" | sort -V | head -n1)" = "$source_pkg_version" ] && return
  
  if [ -f "$target_makefile" ];then
    for k in $keys;do
      v=$(sed -n "s|^$k:=\(.*\)|\1|p" $source_makefile)

      [ -z "$v" ] && continue

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
  source_packages+="applications "
  source_packages+="net/acme-sync "
  source_packages+="net/openvpn-auth "

  source_checkout=
  source_checkout+=$source_packages
  sparse_checkout $source_dir "https://github.com/czy21/openwrt-plugin" "$source_checkout" main
  for t in $source_packages;do
    rsync -avR --delete ${source_dir}/./$t .
  done
}

function sparse_checkout_official() {

  source_packages_dir=feeds/openwrt/packages
  source_packages_pkg=
  source_packages_pkg+="net/adguardhome "
  source_packages_pkg+="net/dnsproxy "

  source_checkout=
  source_checkout+=$source_packages_pkg

  sparse_checkout $source_packages_dir "https://github.com/openwrt/packages" "$source_packages_pkg" $([ "$branch" = "main" ] && echo master || echo $branch)

  for t in $source_packages_pkg;do
    cp_pkg_var $source_packages_dir/$t/Makefile $t/Makefile
  done

}

if [ "$1" == "update" ];then

  sparse_checkout_main
  sparse_checkout_official

  find -name 'Makefile' -type f -not -path './feeds/*' -print0 | while IFS= read -r -d '' t;do
    sed -i \
        -e "s|include ../../luci.mk|include $\(TOPDIR\)/feeds/luci/luci.mk|g" \
        -e "s|include ../../packages/|include $\(TOPDIR\)/feeds/packages/|g" \
        $t
  done

  find -name 'zh-cn' -type d -not -path './feeds/*' -print0 | while IFS= read -r -d '' s;do
    t=$(dirname $s)/zh_Hans
    rm -rf $t && mv -v "$s" "$t"
  done

fi
