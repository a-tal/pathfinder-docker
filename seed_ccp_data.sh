#!/bin/bash
# untar and seed the data as root. set permissions during entrypoint

start_mysql.sh

mysql -uroot -e "create database vanguard;"
echo "--- Importing CCP Data ---"
cd /tmp
tar -xjf mysql-latest.tar.bz2
echo "---    Decompressed    ---"
mysql -uroot vanguard < */*.sql
echo "---  Import Completed  ---"
