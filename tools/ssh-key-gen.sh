#!/bin/bash

echo "Input Your email for this key."
read email
if [ ! "$email" = "" ]; then
    ssh-keygen -t rsa -b 4096 -C "$email"
else
    echo "abort..."
fi

