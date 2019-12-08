#!/bin/bash
./wait-for-it.sh db_tester:3306 -- cpantesters-schema upgrade
if which cpantesters-web; then
    ./wait-for-it.sh db_web:3306 -- cpantesters-web schema upgrade
fi

### Create a metabase instance on the testers database. This will be
# needed until all the backend processes are migrated to the
# CPAN::Testers::Backend project and updated to use the primary database.
# Generated with:
#       mysqldump --defaults-file=~/.cpanstats.cnf --no-data --databases metabase
# and then edited to add "IF NOT EXISTS" so that it can be run
# repeatedly. This database should not change, because we're trying to
# get rid of it. New features should be added to the testers database,
# not the metabase.
mysql --defaults-file=~/.cpanstats.cnf < ./metabase-schema.sql
# Legacy tables that will need updating for now.
# Generated with:
#       mysqldump --defaults-file=~/.cpanstats.cnf --no-data --databases cpanstats --tables page_requests
# and then edited to add "IF NOT EXISTS" so that it can be run
mysql --defaults-file=~/.cpanstats.cnf < ./legacy-schema.sql

