#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=cpanstats-web2.lock
LOG=cron/autorun-web2.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Web 2 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG
    bash cpanstats-web2.sh >>$LOG 2>&1
    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
