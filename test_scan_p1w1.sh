#!/bin/bash
source test_utils.sh

ROOT=$(pwd)
ED1="${ROOT}/ED1"

function setup() {
    rm -rf ${ED1}

    # install
    mkdir -p ${ED1}/dir
    cp scan.sh scan.conf ${ED1}
    cp watch.sh watch.conf ${ED1}

    # prepare data
    cd ${ED1}
    gen_dbtag "dir/DC1" 1 1
    gen_dbtag "dir/DC2" 1 0
}

function execute() {
    cd ${ED1}

    ./scan.sh
}

function verify() {
    cd ${ED1}

    # prepare the expected result
    > watch.ans
    gen_answer "dir/DC2"
    cat watch.ans

    # compare
    diff watch.log watch.ans && echo "Pass" || echo "Failed"
}

function cleanup() {
    rm -rf ${ED1}
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
