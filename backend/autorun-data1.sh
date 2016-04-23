#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-data1.lock
LOG=$BASE/cron/autorun-data1.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Data 1 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    cd $BASE/uploads
    mkdir -p logs
    mkdir -p data

    perl bin/uploads.pl --config=data/uploads.ini -u >>$LOG 2>&1

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
