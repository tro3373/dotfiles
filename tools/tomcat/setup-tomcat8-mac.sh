#!/bin/bash

set -eu

DIR=~/Downloads/Tomcat
mkdir -p $DIR
cd $DIR
wget http://ftp.jaist.ac.jp/pub/apache/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz
tar xvfpz apache-tomcat-8*
cd apache-tomcat-8*
chmod +x bin/*.sh

