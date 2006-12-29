#!/bin/sh

curl http://dev.mysql.com/get/Downloads/MySQL-5.0/mysql-5.0.27.tar.gz/from/pick |
  grep /get/Downloads/MySQL-5.0/mysql-5.0.27.tar.gz/from/ |
  sed -e 's|^.*<h2>Europe</h2>||' |
  perl -pe 's|<a href="(.*?)">.?.?TP</a>|\n\1\n|g' |
  grep "^/get" |
  grep -e "from/http" -e "from/ftp" |
  sed -e 's|/get/Downloads/MySQL-5.0/mysql-5.0.27.tar.gz/from/||g' 
