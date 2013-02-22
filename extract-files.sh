#!/bin/sh

VENDOR=samsung
DEVICE=fascinatemtd

BASE=../../../vendor/$VENDOR/$DEVICE/proprietary
rm -rf $BASE/*
CMD="adb pull "

if [ -e "$1" ]; then
    rm -rf tmp
    mkdir tmp
    if ! unzip -q "$1" -d tmp; then
        echo Failed to unzip "$1"
        exit 1
    fi
    CMD="cp tmp"
fi

for FILE in `cat proprietary-files.txt | grep -v ^# | grep -v ^$`; do
    DIR=`dirname $FILE`
    if [ ! -d $BASE/$DIR ]; then
        mkdir -p $BASE/$DIR
    fi
    if ! $CMD/system/$FILE $BASE/$FILE; then
        echo Failed to pull or copy $FILE
        exit 1
    fi
done

rm -rf tmp

./setup-makefiles.sh
