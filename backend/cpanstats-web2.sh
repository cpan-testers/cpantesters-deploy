#!/usr/bin/bash

BASE=/opt/projects/cpantesters
LOG=$BASE/cron/cpanstats-web2.log

date_format="%Y/%m/%d %H:%M:%S"
echo `date +"$date_format"` "START" >>$LOG

echo `date +"$date_format"` "Parsing Builder logs" >>$LOG
cd /var/www/reports/toolkit
perl log-parser.pl >>$LOG 2>&1

echo `date +"$date_format"` "Creating cpanstats matrix files" >>$LOG
cd $BASE/cpanstats
mkdir -p logs
mkdir -p data

# takes the longest to run
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --noreports                        >>$LOG 2>&1

#     --matrix                           \

# build the cpan/backpan 100
perl bin/cpanstats-writepages   	\
     --config=data/settings.ini		\
     --cpan                             >>$LOG 2>&1

#     --logfile=$LOG			\
#     --logclean=1			\

cd $BASE/cpanstats-excel
mkdir -p logs

echo `date +"$date_format"` "Creating cpanstats excel files" >>$LOG
perl bin/cpanstats-writeexcel >>$LOG 2>&1

cd /var/www/reports/toolkit
perl reports-stats.pl >>LOG 2>&1

echo `date +"$date_format"` "STOP" >>$LOG

