#!/bin/bash
source watch.conf

dir=$1
done_parse=${dir}/${done_parse}
done_watch=${dir}/${done_watch}

inotifywait -m -r --format '%w%f' -e close_write ${dir} |
  while read file; do
    if [[ ${file} == ${done_parse} ]]; then
        touch ${done_watch}
        killall watch.sh
    fi
    echo ${file} >> ${log} 
  done
