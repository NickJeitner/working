#!/bin/bash

[[ $( systemctl is-active ceph-mgr.target ) != "active" ]] && exit

declare -A clients

for inst in $( rbd ls vmimages | sort -u )
do
    prefix=$( rbd info vmimages/${inst} | awk -F. '/prefix/ {print $NF}' )
    watchers=$( rados -p vmimages listwatchers rbd_header.${prefix} | awk -F'[=|:]' '{print $2}' )
    [[ -n "${watchers}" ]] && host=$( dig +short -x ${watchers} )
    clients[${host%%.*}]+="${inst} "
done

for inst in "${!clients[@]}"
do
    printf "%s:" ${inst}
    for dev in ${clients[$inst]}
    do
        [[ ${name:-''} == ${dev%%_*} ]] && printf " %s" ${dev#*_} && continue
        name=${dev%%_*}
        printf "\n\t%-26s: %s" ${name} ${dev#*_}
    done
    echo
done

exit
