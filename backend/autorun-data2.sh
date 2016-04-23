#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-data2.lock
LOG=$BASE/cron/autorun-data2.log

date_format="%Y/%m/%d %H:%M:%S"
DATE2=`date +"%Y%m%d"`
DATE3=`date +"%Y-%m-%dT00:00:00Z" --date='7 days ago'`

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Data 2 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    cd $BASE/generate
    mkdir -p logs

    # find missing ranges
    perl bin/find-missing-report-ranges.pl --config=data/settings.ini --from=$DATE3 >parselog.$DATE2.log 2>>$LOG
    cp parselog.$DATE2.log regenerate.txt

    # download any missing reports
    perl bin/cpanstats -c=data/regenerate.ini --regenerate --file=regenerate.txt >>logs/regenerate.log 2>>$LOG

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi

