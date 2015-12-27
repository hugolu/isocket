#!/bin/bash
source scan.conf

function scandir() {
    dbtags=$(ls ${dir} | grep ${tag} | sort)
    for dbtag in ${dbtags}
    do
        [ -e ${dir}/${dbtag}/${done_parse} ] && parse=1 || parse=0
        [ -e ${dir}/${dbtag}/${done_watch} ] && watch=1 || watch=0
        echo "${dbtag} parse=${parse}, watch=${watch}"
        
        if [ ${watch} == 1 ]; then
            # watch done
            continue
        fi

        for file in $(ls -tr ${dir}/${dbtag})
        do
            echo ${dir}/${dbtag}/${file} >> ${log}
        done

        if [ ${parse} == 1 ]; then
            # parse done
            touch ${dir}/${dbtag}/${done_watch}
            continue
        fi

        # parse ongoing
        ${watch} ${dir}/${dbtag}
    done
}

while true
do
    scandir
    [ $(basename $0) == "scan.daemon" ] || break
    sleep ${check_interval}
done
