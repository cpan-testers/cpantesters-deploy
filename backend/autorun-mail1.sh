#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-mail1.lock
LOG=$BASE/cron/autorun-mail1.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Mailer 1 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    cd $BASE/reports-mailer
    mkdir -p logs

    perl bin/getmailrc.pl

    # run the daily reports
    echo `date +"$date_format"` "mode=daily" >>$LOG
    perl bin/cpanreps-mailer --config=data/preferences-daily.ini >>$LOG 2>&1

    # run the named weekly reports
    day=`date +"%a"`
    echo `date +"$date_format"` "mode=$day" >>$LOG
    perl bin/cpanreps-mailer --config=data/preferences-weekly.ini --mode=$day >>$LOG 2>&1

    # run the generic weekly on a Saturday morning
    if [ `date +"%w"` -eq 6 ]; then
      echo `date +"$date_format"` "mode=weekly" >>$LOG
      perl bin/cpanreps-mailer --config=data/preferences-weekly.ini >>$LOG 2>&1
    fi

    # run the monthly on the first day of the month
    if [ `date +"%-d"` -eq 1 ]; then
      echo `date +"$date_format"` "mode=monthly" >>$LOG
      perl bin/cpanreps-mailer --config=data/preferences.ini --mode=monthly --logfile=logs/monthly-mailer.log >>$LOG 2>&1
    fi

    # produce the individual reports
    echo `date +"$date_format"` "mode=reports" >>$LOG
    perl bin/cpanreps-mailer --config=data/preferences.ini --mode=reports --logfile=logs/reports-mailer.log >>$LOG 2>&1

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
