#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=cpanstats-web3.lock
LOG=cron/autorun-web3.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Web 3 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG
    bash /var/www/cpanstats/cgi-bin/uploads.sh >>$LOG 2>&1
    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
