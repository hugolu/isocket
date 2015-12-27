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
    gen_dbtag "dir/DC1" 0 1
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
    gen_answer "dir/DC2" 1
    cat watch.ans

    # compare
    diff watch.log watch.ans && echo "Pass" || echo "Failed"
}

function cleanup() {
    rm -rf ${ED1}
}

main $@
