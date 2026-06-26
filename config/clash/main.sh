#!/bin/bash
cd $(cd "$(dirname "$0")"; pwd)

[ -d "metatube-sdk-go/.git" ] || git clone https://github.com/metatube-community/metatube-sdk-go.git
(cd metatube-sdk-go;git pull)

find ./metatube-sdk-go/provider -name '*.go' -exec sh -c 'sed -n "s|baseURL\(.*\)\"\(.*\)\"|\2|p" {} | cut -d"/" -f3' \; | awk '{ split($0, arr, "."); if (length(arr)>2) {print substr($0,length(arr[1])+2)} else {print $0}; }' | sort | uniq | sed -e "s|^|DOMAIN-SUFFIX,|" -e "/github/d" > MetaTube.list