#!/bin/bash

set -eu

DIR=~/Downloads/Tomcat
mkdir -p $DIR
cd $DIR
wget http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/tomcat/tomcat-6/v6.0.44/bin/apache-tomcat-6.0.44.tar.gz
tar xvfpz apache-tomcat*
cd apache-tomcat*
chmod +x bin/*.sh

