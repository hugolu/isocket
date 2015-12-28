#!/bin/bash
source "test/utils.sh"

ROOT=$(pwd)
ED1="${ROOT}/ED1"
DRMS="${ROOT}/DRMS"

function setup() {
    rm -rf ${ED1}
    rm -rf ${ED2}

    # install
    mkdir -p ${ED1}/dir
    cp scan.sh ${ED1}/scan.daemon
    cp scan.conf ${ED1}
    cp watch.sh watch.conf ${ED1}
    cp fsync.sh ${ED1}/fsync.daemon
    cp fsync.conf ${ED1}
    cp utils.lua lsocket.client lsocket.conf ${ED1}

    mkdir -p ${DRMS}/dir
    cp utils.lua lsocket.server lsocket.conf ${DRMS}
}

function execute() {
    # run DRMS
    start_daemon ${DRMS}/lsocket.server

    # run ED1
    start_daemon ${ED1}/scan.daemon
    start_daemon ${ED1}/fsync.daemon
    sleep 1

    # generate data
    gen_files ${ED1}/dir/DC1 0
    gen_files ${ED1}/dir/DC2 0
    gen_files ${ED1}/dir/DC3 0
    sleep 5

    # stop ED1
    stop_daemon ${ED1}/scan.daemon
    stop_daemon ${ED1}/fsync.daemon

    # stop DRMS
    stop_daemon ${DRMS}/lsocket.server
}

function verify() {
    assertTrue chk_files "${ED1}/dir/DC1" "${DRMS}/dir/DC1" 1
    assertTrue chk_files "${ED1}/dir/DC2" "${DRMS}/dir/DC2" 1
    assertTrue chk_files "${ED1}/dir/DC3" "${DRMS}/dir/DC3" 1
}

function cleanup() {
    rm -rf ${ED1}
    rm -rf ${DRMS}
}

do_test $@
