# mysql-master-slave
mysql master and mysql slave proxed with haproxy, phpmyadmin - sollution with docker compose. Simple installation with one script.

## install
~~~shell
bash install.sh
# after install check http://localhost:8080/
~~~

## remove mysql data and reinstall
~~~shell
docker-compose down && sudo rm -rf storage/* && rm .env && bash install.sh
~~~
