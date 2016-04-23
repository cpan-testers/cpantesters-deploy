#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-back2.lock
LOG=$BASE/cron/autorun-back2.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Backup 2 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    echo `date +"$date_format"` "Backing up Uploads data..." >>$LOG

    cd $BASE/uploads
    mkdir -p logs
    mkdir -p data

    perl bin/uploads.pl --config=data/uploads.ini -b >>$LOG 2>&1

    echo `date +"$date_format"` "Compressing Uploads data..." >>$LOG

    cd $BASE/dbx
    rm -f uploads.*
    cp $BASE/uploads/data/uploads.db .  ; gzip  uploads.db
    cp $BASE/uploads/data/uploads.db .  ; bzip2 uploads.db

    mkdir -p /var/www/cpandevel/uploads
    mv uploads.* /var/www/cpandevel/uploads

    echo `date +"$date_format"` "Checking Uploads data..." >>$LOG

    cd $BASE/uploads-mailer
    perl bin/uploads-mailer.pl >>$LOG 2>&1

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
