#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=cpanstats-web1.lock
LOG=cron/autorun-web1.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Web 1 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG
    bash cpanstats-web1.sh >>$LOG 2>&1
    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
