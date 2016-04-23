#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-data3.lock
LOG=$BASE/cron/autorun-data3.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Data 3 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    cd $BASE/generate
    mkdir -p logs

    perl bin/cpanstats --config=data/settings.ini >>$LOG 2>&1

#    perl -d:NYTProf bin/cpanstats --config=data/settings.ini --nonstop >>$LOG
#    perl bin/cpanstats --config=data/settings.ini >>$LOG

#perl bin/readstats.pl -c -m >logs/readstats.out

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
