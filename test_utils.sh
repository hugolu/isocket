#!/bin/bash

function gen_files() {
    dir=$1
    synced=$2

    mkdir ${dir}

    for ((i=0; i<3; i++)); do
        timestamp=$(printf "15122500%02d.00" ${i})
        dd if=/dev/urandom of=${dir}/file${i} bs=1k count=1 2>/dev/null
        touch -t ${timestamp} ${dir}/file${i}
        if [ $synced == "1" ]; then
            chmod g+w ${dir}/file${i}
        fi
    done

    timestamp=$(printf "15122500%02d.00" ${i})
    touch -t ${timestamp} ${dir}/finished.parse
}

function chk_files() {
    src=$1
    dst=$2
    exist=$3

    if [ ${exist} == 0 ]; then
        [ -d ${dst} ] && return 0 || return 1
    fi

    files=$(ls ${dst} | grep "file")
    for file in ${files}
    do
        diff ${src}/${file} ${dst}/${file} >/dev/null || return 1
    done

    return 0
}

function gen_dbtag() {
    dir=$1
    parse_mark=$2
    watch_mark=$3

    mkdir ${dir}

    for ((i=0; i<3; i++)); do
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/file${i}
    done

    if [ ${parse_mark} != "0" ]; then
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/finished.parse
    fi

    if [ ${watch_mark} != "0" ]; then
        timestamp=$(printf "15122500%02d.00" ${i})
        touch -t ${timestamp} ${dir}/finished.watch
    fi
}

function gen_answer() {
    dir=$1 
    parse_mark=$2

    for ((i=0; i<3; i++)); do
        echo "${dir}/file${i}" >> watch.ans
    done

    if [ ${parse_mark} != "0" ]; then
        echo ${dir}/finished.parse >> watch.ans
    fi
}

function start_daemon() {
    dir=$1
    daemon=$2

    cd ${dir}
    ${dir}/${daemon} &
    echo $! > ${dir}/${daemon}.pid
}

function stop_daemon() {
    dir=$1
    daemon=$2

    pid=$(cat ${dir}/${daemon}.pid)
    echo "stop ${dir}/${daemon} (${pid})"
    kill -9 ${pid}
}

function main() {
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
}
