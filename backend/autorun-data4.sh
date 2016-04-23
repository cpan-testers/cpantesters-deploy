#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-data4.lock
LOG=$BASE/cron/autorun-data4.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Data 4 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    cd $BASE/generate
    mkdir -p logs

    #perl bin/metabase-tail.pl >>logs/metabase-tail.log 2>>logs/metabase-tail.err
    bash tail.sh >>$LOG 2>&1

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
