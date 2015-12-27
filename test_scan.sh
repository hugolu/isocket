#!/bin/bash

ROOT=$(pwd)
ED1="${ROOT}/ED1"

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

function cleanup() {
    rm -rf ${ED1}
}

function setup() {
    cleanup

    cd ${ROOT}
    mkdir -p ${ED1}/dir
    cp scan.sh scan.conf ${ED1}
    cp watch.sh watch.conf ${ED1}

    cd ${ED1}
    gen_dbtag "dir/DC1"
    gen_dbtag "dir/DC2"
    gen_dbtag "dir/DC3"
}

function execute() {
    cd ${ED1}

    ./scan.sh

    #sleep 1
    #kill -9 $(cat scan.pid) 2>/dev/null
}

function verify() {
    cd ${ED1}

    > watch.ans
    gen_answer "dir/DC1"
    gen_answer "dir/DC2"
    gen_answer "dir/DC3"
    cat watch.ans

    diff watch.log watch.ans && echo "Pass" || echo "Failed"
}

if [ $# == 0 ]; then
    echo "==== setup"
    setup

    echo "==== execute"
    execute

    echo "==== verify"
    verify

    echo "==== cleanup"
    cleanup
else
    case $1 in
        "setup")
            setup
            ;;

        "execute")
            execute
            ;;

        "verify")
            verify
            ;;

        "cleanup")
            cleanup
            ;;

        *)
            echo "setup | execute | verify | cleanup"
            ;;
    esac
fi
