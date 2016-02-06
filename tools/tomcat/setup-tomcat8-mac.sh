#!/bin/bash

set -eu

DIR=~/Downloads/Tomcat
mkdir -p $DIR
cd $DIR
#wget http://ftp.jaist.ac.jp/pub/apache/tomcat/tomcat-8/v8.0.28/bin/apache-tomcat-8.0.28.tar.gz
wget http://ftp.kddilabs.jp/infosystems/apache/tomcat/tomcat-8/v8.0.30/bin/apache-tomcat-8.0.30.tar.gz
tar xvfpz apache-tomcat-8*
cd apache-tomcat-8*
chmod +x bin/*.sh

