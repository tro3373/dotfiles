#!/bin/bash

rules=/etc/udev/rules.d/51-android.rules
if [[ -e $rules ]]; then
    echo "Already exist rules. $rules"
    exit 1
fi
sudo cp ./etc_udev_rules.d_51-android.rules $rules
sudo service udev restart
echo done
