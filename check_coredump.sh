#!/bin/sh
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:$PATH
CAGENT_CMD=/usr/bin/cagent_tools
cnt=$(ls -l /data/corefile/ | wc -l)
if [ $cnt -ne 1 ] ; then
    # alarm content
    let coredump=$cnt-1
    cagent_tools alarm "find $coredump coredump file! "
fi
