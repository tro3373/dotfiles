#!/bin/bash

wbinfo=/usr/local/samba/bin/wbinfo
$wbinfo --help | fzf
