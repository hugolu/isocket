#!/bin/bash
source "test/utils.sh"

ROOT=$(pwd)
ED1="${ROOT}/ED1"
DRMS="${ROOT}/DRMS"

function setup() {
    rm -rf ${ED1}
    rm -rf ${DRMS}

    # install
    mkdir -p ${ED1}/dir
    cp scan.sh scan.conf ${ED1}
    cp watch.sh watch.conf ${ED1}
    cp fsync.sh fsync.conf ${ED1}
    cp utils.lua lsocket.client lsocket.conf ${ED1}

    mkdir -p ${DRMS}/dir
    cp utils.lua lsocket.server lsocket.conf ${DRMS}

    # prepare data
    cd ${ED1}
    gen_files "dir/DC1" 1
    gen_files "dir/DC2" 0
}

function execute() {
    # run DRMS
    start_daemon ${DRMS} lsocket.server

    # run ED1
    cd ${ED1}
    ./scan.sh
    ./fsync.sh

    # stop DRMS
    stop_daemon ${DRMS} lsocket.server
}

function verify() {
    chk_files "${ED1}/dir/DC1" "${DRMS}/dir/DC1" 0 && echo "Pass" || echo "Failed"
    chk_files "${ED1}/dir/DC2" "${DRMS}/dir/DC2" 1 && echo "Pass" || echo "Failed"
}

function cleanup() {
    rm -rf ${ED1}
    rm -rf ${DRMS}
}

do_test $@
