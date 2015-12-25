#!/bin/bash

ROOT=$(pwd)
ED1="${ROOT}/ED1"

function gen_dbtag() {
    dir=$1

    mkdir ${dir}
    for ((i=0; i<3; i++)); do
        touch ${dir}/file${i}
        sleep 1
    done
    touch ${dir}/finished.parse
}

function chkfile() {
    :
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

    gen_dbtag "${ED1}/dir/DC1"
    gen_dbtag "${ED1}/dir/DC2"
}

function execute() {
    cd ${ED1}

    ./scan.sh &
    echo $! > scan.pid

    sleep 1

    kill -9 $(cat scan.pid)
}

function verify() {
    :
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
