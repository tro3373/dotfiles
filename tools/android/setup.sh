#!/bin/bash

# Install java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

# sudo apt-get install android-tools-adb

sudo apt-get install libc6-i386 libncurses5:i386 libstdc++6:i386

# Install android studio build libs
sudo apt-get install lib32stdc++6
sudo apt-get install lib32z1
