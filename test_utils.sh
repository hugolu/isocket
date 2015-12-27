#!/bin/bash

function gen_dbtag() {
    dir=$1
    parse_mark=$2
    watch_mark=$3

    mkdir ${dir}

    for ((i=0; i<3; i++)); do
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/file${i}
    done

    if [ ${parse_mark} != "0" ]; then
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/finished.parse
    fi

    if [ ${watch_mark} != "0" ]; then
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/finished.watch
    fi
}

function gen_answer() {
    dir=$1 
    parse_mark=$2

    for ((i=0; i<3; i++)); do
        echo "${dir}/file${i}" >> watch.ans
    done

    if [ ${parse_mark} != "0" ]; then
        echo ${dir}/finished.parse >> watch.ans
    fi
}
