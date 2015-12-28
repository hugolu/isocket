#!/bin/bash
source "test/utils.sh"

ROOT=$(pwd)
ED1="${ROOT}/ED1"
ED2="${ROOT}/ED2"
DRMS="${ROOT}/DRMS"

function setup() {
    rm -rf ${ED1}
    rm -rf ${ED2}
    rm -rf ${DRMS}

    # install
    mkdir -p ${ED1}/dir
    cp scan.sh ${ED1}/scan.daemon
    cp scan.conf ${ED1}
    cp watch.sh watch.conf ${ED1}
    cp fsync.sh ${ED1}/fsync.daemon
    cp fsync.conf ${ED1}
    cp utils.lua lsocket.client lsocket.conf ${ED1}

    mkdir -p ${ED2}/dir
    cp scan.sh ${ED2}/scan.daemon
    cp scan.conf ${ED2}
    cp watch.sh watch.conf ${ED2}
    cp fsync.sh ${ED2}/fsync.daemon
    cp fsync.conf ${ED2}
    cp utils.lua lsocket.client lsocket.conf ${ED2}

    mkdir -p ${DRMS}/dir
    cp utils.lua lsocket.server lsocket.conf ${DRMS}
}

function execute() {
    # run DRMS
    start_daemon ${DRMS}/lsocket.server

    # run ED1
    start_daemon ${ED1}/scan.daemon
    start_daemon ${ED1}/fsync.daemon

    # run ED2
    start_daemon ${ED2}/scan.daemon
    start_daemon ${ED2}/fsync.daemon

    # generate data
    gen_files ${ED1}/dir/DC1 0
    gen_files ${ED2}/dir/DC4 0
    gen_files ${ED1}/dir/DC2 0
    gen_files ${ED2}/dir/DC5 0
    gen_files ${ED1}/dir/DC3 0
    gen_files ${ED2}/dir/DC6 0
    sleep 5

    # stop ED1
    stop_daemon ${ED1}/scan.daemon
    stop_daemon ${ED1}/fsync.daemon

    # stop ED2
    stop_daemon ${ED2}/scan.daemon
    stop_daemon ${ED2}/fsync.daemon

    # stop DRMS
    stop_daemon ${DRMS}/lsocket.server
}

function verify() {
    assertTrue chk_files "${ED1}/dir/DC1" "${DRMS}/dir/DC1" 1
    assertTrue chk_files "${ED1}/dir/DC2" "${DRMS}/dir/DC2" 1
    assertTrue chk_files "${ED1}/dir/DC3" "${DRMS}/dir/DC3" 1

    assertTrue chk_files "${ED2}/dir/DC4" "${DRMS}/dir/DC4" 1
    assertTrue chk_files "${ED2}/dir/DC5" "${DRMS}/dir/DC5" 1
    assertTrue chk_files "${ED2}/dir/DC6" "${DRMS}/dir/DC6" 1
}

function cleanup() {
    rm -rf ${ED1}
    rm -rf ${ED2}
    rm -rf ${DRMS}
}

do_test $@
