#!/bin/bash

PATH=/usr/local/samba/bin:$PATH
IFS=$'\n'
for s4u in $(wbinfo -u); do wbinfo --user-info=$s4u; done
