#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOCK=$BASE/cpanstats-back1.lock
LOG=$BASE/cron/autorun-back1.log

date_format="%Y/%m/%d %H:%M:%S"

cd $BASE

clean_backup() {
    PREFIX=$1
    # Remove the previous backup, leaving 2
    perl -E'@f = sort glob($ARGV[0] . "*.sql*"); @r = splice @f, 0, -2; unlink for @r' $PREFIX
}

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "Backup 1 already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG

    DATE=`date +"%Y%m%d"`

    cd $BASE/dbx

    clean_backup metabase-email-backup
    mysqldump -u barbie --skip-add-locks --add-drop-table --skip-disable-keys --skip-extended-insert metabase testers_email | bzip2 >metabase-email-backup-$DATE.sql

    clean_backup testers-backup
    mysqldump -u barbie --skip-add-locks --add-drop-table --skip-disable-keys --skip-extended-insert testers | bzip2 >testers-backup-$DATE.sql

    clean_backup cpanstats-backup
    mysqldump -u barbie --skip-add-locks --add-drop-table --skip-disable-keys --skip-extended-insert cpanstats >cpanstats-backup-$DATE.sql
    bzip2 cpanstats-backup-$DATE.sql

    # The previous two millions
    clean_backup metabase-67m-backup
    mysqldump -u barbie --skip-add-locks --where="id>66000000 AND id<=67000000" --skip-disable-keys --skip-extended-insert metabase metabase >metabase-67m-backup-$DATE.sql
    bzip2 metabase-67m-backup-$DATE.sql
    clean_backup metabase-68m-backup
    mysqldump -u barbie --skip-add-locks --where="id>67000000 AND id<=68000000" --skip-disable-keys --skip-extended-insert metabase metabase >metabase-68m-backup-$DATE.sql
    bzip2 metabase-68m-backup-$DATE.sql

    # The current million
    clean_backup metabase-backup
    mysqldump -u barbie --skip-add-locks  --where="id>68000000" --skip-disable-keys --skip-extended-insert metabase metabase >metabase-backup-$DATE.sql
    bzip2 metabase-backup-$DATE.sql

    #cp ../db/cpanstats.db cpanstats-$DATE.db
    #bzip2 cpanstats-$DATE.db

    #cd $BASE/generate

    #echo `date +"$date_format"` "Updating SQLite cpanstats data..." >>$LOG
    #perl bin/cpanstats-sqlite --config=data/settings.ini >>$LOG 2>&1

    #cd $BASE/dbx

    #echo `date +"$date_format"` "Compressing cpanstats data..." >>$LOG
    #cp $BASE/db/cpanstats.db .  ; gzip  cpanstats.db
    #cp $BASE/db/cpanstats.db .  ; bzip2 cpanstats.db

    #mv cpanstats.* /var/www/cpandevel

    echo `date +"$date_format"` "STOP" >>$LOG

    rm $LOCK
fi
