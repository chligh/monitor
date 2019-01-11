#!/bin/sh -x
PATH="/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:."
source /etc/profile

Usage(){
    echo 
    echo "Usage: $0 [app_name] [app_args]"
    echo "Note: if monitor.ini does not exist,app_name must be assigned as parameter!"
    echo "Suggestion:running under cron."
    echo ""
}


#==============================
#save log.
# if logfile is not set,just echo to studout.
#
Log(){
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> ${WORK_DIR}/monitor.log
}

#=============================
#config variable.
#
Config(){
    WORK_DIR=`dirname "$0"`
#    IP=`/sbin/ifconfig eth1:0|grep "inet addr:"|awk -F: '{print$2}'|awk '{print$1}'`
#    IP=`ifconfig |grep "inet addr:"|awk '{print $2}'|awk -F: '{print $2}'|grep -E "^172|^10"|head -1`
     IP=`/sbin/ifconfig | awk '/eth1/{getline; print}' | awk '{print $2}' | sed "s/addr://g" | grep "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | grep -v "127.0.0.1" | sed -n "1p"`

    if [ ! -e ${WORK_DIR}/monitor.ini ] ; then
        MONITER_SWITCH=1
        IS_RESTART=0
        APP_USER0="root"
        APP_DIR0=${WORK_DIR}
        APP_NAME0=$1
        APP_ARGS0=$2
        APP_COUNT=1
        msg="$IP count not find monitor.ini,so load default config."
        Log "$msg"
    else 
        source ${WORK_DIR}/monitor.ini
    fi
}


#=============================
#monitor the application precess.
#
Moniter(){
    if (( ${MONITER_SWITCH}==0 )) ; then
        echo "monitor status is desable,so exit."
        exit 1
    fi

    count=0
    while (( ${count} < ${APP_COUNT} )) ; do
        local app="APP_DIR"
        local dir=\$"$app$count"
        APP_DIR=`eval echo $dir`

        local app="APP_USER"
        local user=\$"$app$count"
        APP_USER=`eval echo $user`

        local app="APP_NAME"
        local name=\$"$app$count"
        APP_NAME=`eval echo $name`

        local app="APP_ARGS"
        local args=\$"$app$count"
        APP_ARGS=`eval echo $args`

        proNum=`ps -e -o ruser=useruseruser9 -o pid,ppid,c,stime,tty,time,cmd|grep "${APP_NAME}" |grep "${APP_USER} "|grep -v "_${APP_USER}"|grep -v "monitor.sh"|grep -v grep|wc -l`
        
        if (( ${proNum}==0 )) ; then
            msg="[$(date "+%H:%M:%S")]:${IP}:${APP_NAME} has disappeared."
            Log "$msg"
            if (( ${IS_RESTART}==1 )) ; then
                su - ${APP_USER} -c "(cd ${APP_DIR};./${APP_NAME} ${APP_ARGS} &)"
                msg="[$(date "+%H:%M:%S")]:${IP}:${APP_NAME} has started up."
                Log "$msg"
            fi

        fi
        
        sleep 1
        count=$((count+1))
    done
}


#=============================
# main : script start here
#
if [[ _"$1" = _"-h" || _"$1" = _"--help" ]] ; then
    Usage
    exit 1
fi

if [ ! -e `dirname "$0"`/monitor.ini ] && (( $# < 1 )) ; then
    Usage
    exit 1
fi

Config "$@"
Moniter
