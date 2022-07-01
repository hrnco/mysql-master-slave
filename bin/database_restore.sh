#!/usr/bin/env bash

if test -z "$1"
then
echo "usage: $0 [file] [database]"
exit
fi

if test -z "$2"
then
echo "usage: $0 [file] [database]"
exit
fi

FILE=$1
FILE=$(realpath "$FILE")
cd $(dirname "$0")
cd ..
DIR=$(pwd)

MYSQL_DATABASE=$2
MYSQL_ROOT_PASSWORD=$(source .env; echo $MYSQL_ROOT_PASSWORD);

docker-compose exec mysql_master mysql -u root -p$(source .env; echo $MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE IF NOT EXISTS $(source .env; echo $MYSQL_DATABASE) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
cat $FILE | docker-compose exec -u root -T mysql_master mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE
