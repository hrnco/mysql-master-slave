#!/usr/bin/env bash

set -e

cd $(dirname "$0")
DIR=$(pwd)

run_query()
{
  CONTAINER=$1
  MYSQL_QUERY=$2
  echo "run query on container $CONTAINER: $MYSQL_QUERY"
  docker compose exec $CONTAINER mysql -h "$CONTAINER" -p$MYSQL_ROOT_PASSWORD -e "$MYSQL_QUERY"
}

db_server_pripraveny()
{
  kontainer=$1
  echo "overujem, ci je mysql server $kontainer nainstalovany, inicializovany a spusteny"
  while ! docker compose exec $kontainer mysqladmin ping -h "$kontainer" -p$MYSQL_ROOT_PASSWORD --silent; do
    echo -ne '.'
    sleep 1
  done
}

cd $DIR

if test -f ".env"; then
    echo ".env already exists!"
    exit 1
fi

read -s -p "Enter mysql root password: "  MYSQL_ROOT_PASSWORD

echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" > .env

mkdir -p storage/mysql/master storage/mysql/slave

docker compose up -d

db_server_pripraveny "mysql_master"

run_query mysql_master "CREATE USER 'replikator'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
run_query mysql_master "GRANT REPLICATION SLAVE ON *.* TO 'replikator'@'%';"
run_query mysql_master "FLUSH PRIVILEGES;"
run_query mysql_master "CREATE USER 'haproxy_check'@'%';"

db_server_pripraveny "mysql_slave"

run_query mysql_slave "CREATE USER 'haproxy_check'@'%';"

sleep 2

MASTER_STATUS=$(run_query mysql_master "show master status" | grep "mysql-bin")
MASTER_LOG_FILE=$( echo $MASTER_STATUS | awk -F' ' '{print $1}')
MASTER_LOG_POS=$( echo $MASTER_STATUS | awk -F' ' '{print $2}')

run_query mysql_slave "CHANGE MASTER TO MASTER_HOST='mysql_master', MASTER_USER='replikator', MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS"
run_query mysql_slave "START SLAVE;"
docker compose restart mysql_slave mysql
