#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-back3.lock
LOG=$BASE/cron/autorun-back3.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Backup 3 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    cd $BASE/release
    mkdir -p logs
    mkdir -p data

    echo `date +"$date_format"` "Archiving Release data..." >>$LOG

    perl bin/release.pl --config=data/release.ini

    echo `date +"$date_format"` "Compressing Release data..." >>$LOG

    DB=$BASE/release/data/release.db

    if [ -f $DB ]
    then
        cd $BASE/db
        cp $DB .

        cd $BASE/dbx
        rm -f release.*

        echo `date +"$date_format"` ".. compressing with gzip" >>$LOG
        cp $DB .  ; gzip  release.db

        echo `date +"$date_format"` ".. compressing with bzip" >>$LOG
        cp $DB .  ; bzip2 release.db

        echo `date +"$date_format"` ".. compressed" >>$LOG

        mkdir -p /var/www/cpandevel/release
        mv release.* /var/www/cpandevel/release
    fi

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
