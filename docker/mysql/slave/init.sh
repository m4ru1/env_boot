#!/bin/bash
set -e

# Start mysqld in the background
docker-entrypoint.sh mysqld &

# Wait for the slave's mysqld to be ready
until mysqladmin ping -h"localhost" -u"root" -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    echo 'waiting for slave mysqld to be ready...'
    sleep 2
done

# Wait for the master's mysqld to be ready
until mysqladmin ping -h"mysql-master" -u"${MYSQL_REPLICATION_USER}" -p"${MYSQL_REPLICATION_PASSWORD}" --silent; do
    echo 'waiting for master mysqld to be ready...'
    sleep 2
done

echo "Slave and Master are ready, configuring replication."

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
STOP REPLICA;
RESET REPLICA ALL;
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='${MYSQL_REPLICATION_USER}',
  MASTER_PASSWORD='${MYSQL_REPLICATION_PASSWORD}',
  MASTER_AUTO_POSITION=1;
START REPLICA;
"

echo "Replication configured."

# Bring the background mysqld process to the foreground
wait 