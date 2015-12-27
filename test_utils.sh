#!/bin/bash

function gen_dbtag() {
    dir=$1
    mkdir ${dir}

    for ((i=0; i<3; i++)); do
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/file${i}
    done

    timestamp=$(printf "15122500%02d.00" ${i})
    touch -t ${timestamp} ${dir}/finished.parse
}

function gen_answer() {
    dir=$1 

    for ((i=0; i<3; i++)); do
        echo "${dir}/file${i}" >> watch.ans
    done
    echo ${dir}/finished.parse >> watch.ans
}
