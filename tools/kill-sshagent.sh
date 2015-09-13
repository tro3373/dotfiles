#!/bin/bash

echo "bef________"
ps aux |grep ssh-agent |grep -v grep
echo "killing...."
ps aux |grep ssh-agent |grep -v grep |awk {'print "kill -9 "$2'} | sh
echo "aft________"
ps aux |grep ssh-agent |grep -v grep

