#!/bin/bash
source scan.conf

function scandir() {
    dbtags=$(ls -tr ${dir} | grep ${tag})
    last=$(ls -tr ${dir} | grep ${tag} | tail -n1)

    for dbtag in ${dbtags}
    do
        [ -e ${dir}/${dbtag}/${done_parse} ] && parse_done=1 || parse_done=0
        [ -e ${dir}/${dbtag}/${done_watch} ] && watch_done=1 || watch_done=0
        echo "${dbtag} parse=${parse_done}, watch=${watch_done}"
        
        if [ ${watch_done} == 1 ]; then
            continue
        fi

        for file in $(ls -tr ${dir}/${dbtag})
        do
            if [ ${file} == ${done_parse} ]; then
                continue;
            fi
            echo ${dir}/${dbtag}/${file} >> ${log}
        done

        if [ ${parse_done} == 1 ] || [ ${dbtag} != ${last} ]; then
            touch ${dir}/${dbtag}/${done_watch}
            continue
        fi

        # parse ongoing
        echo "${watch} ${dir}/${dbtag}"
        ${watch} ${dir}/${dbtag}
    done
}

while true
do
    scandir
    [ $(basename $0) == "scan.daemon" ] || break
    sleep ${check_interval}
done
