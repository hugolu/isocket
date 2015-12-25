#!/bin/bash

ROOT=$(pwd)
ED1="${ROOT}/ED1"
ED2="${ROOT}/ED2"
DRMS="${ROOT}/DRMS"

function clean() {
    rm -rf ${DRMS} ${ED1} ${ED2}
}

function start_drms() {
    # clean
    rm -rf ${DRMS}

    # prepare
    cd ${ROOT}
    mkdir -p ${DRMS}/dir
    cp utils.lua lsocket.server lsocket.conf ${DRMS}

    # run
    cd ${DRMS}
    ./lsocket.server &
    echo $! > lsocket.pid
}

function start_ed1() {
    # clean
    rm -rf ${ED1}

    # prepare
    cd ${ROOT}
    mkdir -p ${ED1}/dir/DC1
    cp utils.lua lsocket.client lsocket.conf ${ED1}
    cp watch.sh watch.conf ${ED1}
    cp fsync.sh fsync.conf ${ED1}

    # run
    cd ${ED1}
    ./watch.sh &
    echo $! > watch1.pid
    ./fsync.sh &
    echo $! > fsync1.pid

    # wait for inotify watch established
    sleep 1
}

function start_ed2() {
    # clean
    rm -rf ${ED2}

    # prepare
    cd ${ROOT}
    mkdir -p ${ED2}/dir/DC2
    cp utils.lua lsocket.client lsocket.conf ${ED2}
    cp watch.sh watch.conf ${ED2}
    cp fsync.sh fsync.conf ${ED2}

    # run
    cd ${ED2}
    ./watch.sh &
    echo $! > watch2.pid
    ./fsync.sh &
    echo $! > fsync2.pid

    # wait for inotify watch established
    sleep 1
}

function genfile() {
    for ((i=0; i<10; i++)); do
        for ((j=1; j<=2; j++)) do
            file="${ROOT}/ED${j}/dir/DC${j}/$(printf "file%02d" ${i})"
            dd if=/dev/urandom of=${file} bs=2M count=1
        done
    done
}

function stop_drms() {
    pid_lsocket=$(cat ${DRMS}/lsocket.pid)
    echo "stop drms/lsocket (${pid_lsocket})"
    kill -9 ${pid_lsocket}
}

function stop_ed1() {
    pid_watch1=$(cat ${ED1}/watch1.pid)
    echo "stop ed1/watch (${pid_watch1})"
    kill -9 ${pid_watch1}

    pid_fsync1=$(cat ${ED1}/fsync1.pid)
    echo "stop ed1/fsync (${pid_fsync1})"
    kill -9 ${pid_fsync1}
}

function stop_ed2() {
    pid_watch2=$(cat ${ED2}/watch2.pid)
    echo "stop ed2/watch (${pid_watch2})"
    kill -9 ${pid_watch2}

    pid_fsync2=$(cat ${ED2}/fsync2.pid)
    echo "stop ed2/fsync (${pid_fsync2})"
    kill -9 ${pid_fsync2}
}

function chkfile() {
    for ((i=0; i<10; i++)); do
        for ((j=1; j<=2; j++)) do
            src="${ROOT}/ED${j}/dir/DC${j}/$(printf "file%02d" ${i})"
            dst="${ROOT}/DRMS/dir/DC${j}/$(printf "file%02d" ${i})"
            diff ${src} ${dst}
        done
    done
}

if [ $# == 0 ]; then
    echo "==== start DRMS/ED1/ED1"
    start_drms
    start_ed1
    start_ed2

    echo "==== generate files"
    genfile
    sleep 1

    echo "==== stop DRMS/ED1/ED2"
    stop_ed1
    stop_ed2
    stop_drms

    echo "==== check files"
    chkfile
else
    case $1 in
        "start")
            start_drms
            start_ed1
            start_ed2
            ;;

        "genfile")
            genfile
            ;;

        "stop")
            stop_ed1
            stop_ed2
            stop_drms
            ;;

        "check")
            chkfile
            ;;
                    
        "clean")
            clean
            ;;

        *)
            echo "start | genfile | stop | check | clean | help"
            ;;
    esac
fi
