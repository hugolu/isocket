#!/bin/bash
source fsync.conf

do_fsync()
{
    echo "---------------------------------"
    ./lsocket.client ${tmp}
    if [ $? == 0 ]; then
      rm -f ${tmp}
    else
      sleep ${error_retry_interval}
    fi
}

while [ 1 ]; do
  if [ -f ${tmp} ]; then
    do_fsync
  elif [ -f ${log} ]; then
    mv ${log} ${tmp}
    do_fsync
  else
    sleep ${check_interval}
  fi
done
