#!/bin/bash

[[ $( systemctl is-active ceph-mgr.target ) != "active" ]] && exit

declare -A img

for inst in $( rbd ls vmimages | awk -F_ '{print $1}' | sort -u )
do
    devs="$( rbd ls vmimages | awk -v tgt=${inst} -F_ '$1 == tgt {printf("%s ",$2)}' )"
    img[$inst]=$devs
done

for inst in "${!img[@]}"
do
    printf "%s\n" ${inst}
    for dev in ${img[$inst]}
    do
        prefix=$( rbd info vmimages/${inst}_${dev} | awk -F. '/prefix/ {print $NF}' )
        watchers=$( rados -p vmimages listwatchers rbd_header.${prefix} | awk -F'[=|:]' '{print $2}' )
        if [[ -n "${watchers}" ]]; then
            host=$( dig +short -x ${watchers} )
            printf "\t${dev}: %s\n" ${host%%.*}
        else
            printf "\tNot active\n"
        fi
    done
done
