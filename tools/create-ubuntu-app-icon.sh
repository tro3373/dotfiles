#!/bin/bash

target=./meld.desktop
echo "[Desktop Entry]" >> $target
echo "Type=Application" >> $target
echo "Name=Meld" >> $target
echo "GenericName=meld" >> $target
echo "Icon=/path/to/meld/src/meld-x.x.x/data/icons/hicolor/48x48/apps/meld.png" >> $target
echo "Exec=/path/to/meld/src/meld-1.8.6/bin/meld" >> $target
echo "Terminal=false" >> $target
