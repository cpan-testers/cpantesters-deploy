#!/bin/bash
./wait-for-it.sh db_tester:3306 -- cpantesters-schema upgrade
if which cpantesters-web; then
    ./wait-for-it.sh db_web:3306 -- cpantesters-web schema upgrade
fi
