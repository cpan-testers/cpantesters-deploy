#!/usr/bin/bash

WEB=/var/www
BASE=/opt/projects/cpantesters
LOG=$BASE/cron/cpanstats-web1.log

date_format="%Y/%m/%d %H:%M:%S"
echo `date +"$date_format"` "START" >>$LOG

cd $BASE/cpandevel
mkdir -p logs

echo `date +"$date_format"` "Creating Devel site"  >>$LOG
perl bin/cpandevel-writepages -c=data/settings.ini >>$LOG 2>&1
echo `date +"$date_format"` "Created Devel site"   >>$LOG

cd $WEB/cpanadmin/toolkit
echo `date +"$date_format"` "Updating Testers DB"  >>$LOG
perl build-testers-db.pl --config=data/build-testers-db.ini --verbose --max --build >>$LOG 2>&1
echo `date +"$date_format"` "Updated Testers DB"   >>$LOG
perl maintain-leaderboard.pl --config=data/build-testers-db.ini --verbose >>$LOG 2>&1
echo `date +"$date_format"` "Updated Leaderboard"  >>$LOG

cd $BASE/cpanstats
mkdir -p logs
mkdir -p data

perl bin/getmailrc.pl

echo `date +"$date_format"` "Creating cpanstats basic pages" >>$LOG
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --logclean=1                       \
     --basics --update --stats          >>$LOG 2>&1

echo `date +"$date_format"` "Updating leaderboard table" >>$LOG
perl bin/cpanstats-leaderboard   	\
     --config=data/settings.ini		\
     --update 				>>$LOG 2>&1

echo `date +"$date_format"` "Creating cpanstats site" >>$LOG
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --leader                           >>$LOG 2>&1

#     --logfile=$LOG			\
#     --logclean=1			\

echo `date +"$date_format"` "Creating cpanstats graphs" >>$LOG
perl bin/cpanstats-writegraphs		\
     --config=data/settings.ini         >>$LOG 2>&1

#cd $BASE/cpanstats-excel
#mkdir -p logs
#
#echo `date +"$date_format"` "Creating cpanstats excel files" >>$LOG
#perl bin/cpanstats-writeexcel >>$LOG 2>&1

echo `date +"$date_format"` "STOP" >>$LOG

