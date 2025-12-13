#!/bin/bash

HOME=/app
CPAN=/data/CPAN
BACKPAN=/data/BACKPAN

date_format="%Y/%m/%d %H:%M:%S"

echo $(date +"$date_format") "START"
echo $(date +"$date_format") "copying files from CPAN to BACKPAN"
rsync --exclude CHECKSUMS -vrptgx $CPAN/authors/id/ $BACKPAN/authors/id/ 2>&1

echo $(date +"$date_format") "creating BACKPAN indices"
TMP=$(mktemp -d)
cd $TMP
create-backpan-index -b=$BACKPAN -o=backpan-full-index.txt
create-backpan-index -b=$BACKPAN -r -o=backpan-releases-index.txt
create-backpan-index -b=$BACKPAN -r -order dist -o=backpan-releases-by-dist-index.txt
create-backpan-index -b=$BACKPAN -r -order author -o=backpan-releases-by-age-index.txt
create-backpan-index -b=$BACKPAN -r -order age -o=backpan-releases-by-author-index.txt

echo $(date +"$date_format") "gzipping BACKPAN indices"
gzip backpan-full-index.txt
gzip backpan-releases-index.txt
gzip backpan-releases-by-dist-index.txt
gzip backpan-releases-by-age-index.txt
gzip backpan-releases-by-author-index.txt

mv backpan*index.txt.gz $BACKPAN

cd $HOME
rm -rf $TMP

echo $(date +"$date_format") "STOP"
