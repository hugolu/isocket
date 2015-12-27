#!/bin/bash
source test_utils.sh

ROOT=$(pwd)
ED1="${ROOT}/ED1"

function setup() {
    rmdir ${ED1}

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

function cleanup() {
    rmdir ${ED1}
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
