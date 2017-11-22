#!/bin/bash

LOCK=$HOME/var/run/backpan.lock
CPAN=$HOME/CPAN
BACKPAN=$HOME/BACKPAN
LOG=$HOME/var/log/backpan.log
TMP=$( mktemp -d )

date_format="%Y/%m/%d %H:%M:%S"

cd $TMP

if [ -f $LOCK ]
then
    echo `date +"$date_format"` "BACKPAN update is already running" >>$LOG
else
    touch $LOCK

    echo `date +"$date_format"` "START" >>$LOG
    echo `date +"$date_format"` "copying files from CPAN to BACKPAN" >>$LOG
    rsync --exclude CHECKSUMS -vrptgx $CPAN/authors/id/ $BACKPAN/authors/id/ >>$LOG 2>&1

    echo `date +"$date_format"` "creating BACKPAN indices" >>$LOG
    create-backpan-index -b=$BACKPAN -o=backpan-full-index.txt
    create-backpan-index -b=$BACKPAN -r -o=backpan-releases-index.txt
    create-backpan-index -b=$BACKPAN -r -order dist -o=backpan-releases-by-dist-index.txt
    create-backpan-index -b=$BACKPAN -r -order author -o=backpan-releases-by-age-index.txt
    create-backpan-index -b=$BACKPAN -r -order age -o=backpan-releases-by-author-index.txt

    echo `date +"$date_format"` "gzipping BACKPAN indices" >>$LOG
    gzip backpan-full-index.txt
    gzip backpan-releases-index.txt
    gzip backpan-releases-by-dist-index.txt
    gzip backpan-releases-by-age-index.txt
    gzip backpan-releases-by-author-index.txt

    mv backpan*index.txt.gz $BACKPAN

    cd $HOME
    rm -rf $TMP

    echo `date +"$date_format"` "STOP" >>$LOG
    rm $LOCK
fi

