#!/usr/bin/env bash

cd $(dirname "$0")
cd ..
DIR=$(pwd)

cd $DIR

if test -z "$1"
then
echo "usage: $0 [database]"
exit
fi

MYSQL_DATABASE=$1
MYSQL_ROOT_PASSWORD=$(source .env; echo $MYSQL_ROOT_PASSWORD);

docker-compose exec mysql_master mysqldump -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE
