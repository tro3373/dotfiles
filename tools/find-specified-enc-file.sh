#!/bin/bash

TARGETDIR=${PWD}

if ! type nkf >/dev/null 2>&1; then
    echo "No nkf found error...."
    exit 1
fi

ALLTYPE=""
for file in `find $TARGETDIR -name ".git" -prune -o \
    -type f \( \
        -name "*.MF" -o \
        -name "*.properties" -o \
        -name "*.xml" -o \
        -name "*.html" -o \
        -name "*.js" -o \
        -name "*.css" -o \
        -name "*.jsp" -o \
        -name "*.java" \
    \) -print`; do

    NKFRESULT=`nkf --guess $file`
    if ! echo $ALLTYPE |grep "$NKFRESULT:" >/dev/null 2>&1; then
        ALLTYPE=$NKFRESULT:$ALLTYPE
    fi
    # UTF-8,ASCII以外を検索
    #if echo $NKFRESULT |grep -v "UTF-8" |grep -v "ASCII" >/dev/null 2>&1; then
    # UTF-8,BOM付きを検索
    if echo $NKFRESULT |grep "UTF-8" |grep "BOM" >/dev/null 2>&1; then
        echo $NKFRESULT" ===> "$file
    fi
done

echo -e ""
echo "==> Below type file existed."
for fileType in `echo  $ALLTYPE |sed -e 's/ /@@@/g' |sed -e 's/:/ /g'`; do
    echo "  $fileType" |sed -e 's/@@@/ /g'
done
