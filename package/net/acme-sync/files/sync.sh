#!/bin/bash

# example cron: 0 0 * * * LOG_TAG=acme-sync /etc/acme/sync.sh -t <target_dir> -d example1.com,example2.com

source_dir=/etc/acme
target_dir=
domain_str=
checkend=432000 # 5day
reloadcmd=/etc/acme/post.sh
function usage(){
echo "Usage:
  -d  <x.com,y.com>   Domains
  -s  <source_dir>    Cert source dir (default \"${source_dir}\")
  -t  <target_dir>    Cert target dir
  -c  <command>       Command to execute after installcert (default \"${reloadcmd}\")
  -e  <seconds>       Check whether target cert expires in the next arg seconds (default \"${checkend}\")
  -h
"
exit 2
}

while getopts "d:s:t:c:e:h" opt
do
        case $opt in
                s)
                  source_dir=$OPTARG
                ;;
                t)
                  target_dir=$OPTARG
                ;;
                d)
                  domain_str=$OPTARG
                ;;
                c)
                  reloadcmd=$OPTARG
                ;;
                e)
                  checkend=$OPTARG
                ;;
                h)
                usage
                ;;
                *)
                usage
                ;;
    esac
done

[ -z $domain_str ] && echo "option requires an argument -- d" && usage
[ -z $target_dir ] && echo "option requires an argument -- t" && usage

domains="$(echo $domain_str | tr ',' ' ')"
mkdir -p ${target_dir}
for d in $domains; do
  target_cer=${target_dir}/${d}.cer
  if [[ ! -e ${target_cer} ]] || [[ -e ${target_cer} && $(openssl x509 -in ${target_cer} -noout -enddate -checkend ${checkend} | grep 'will expire') ]];then
    /usr/lib/acme/client/acme.sh --installcert --home ${source_dir} -d ${d} --cert-file ${target_cer} --key-file ${target_dir}/${d}.key --fullchain-file ${target_dir}/${d}.pem --reloadcmd "$reloadcmd" | logger -t "${LOG_TAG}"
  fi
done