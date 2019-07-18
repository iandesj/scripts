#!/usr/bin/env bash

SLEEP=2

if [ $# -ne 2 ]; then
    echo "Usage: $0 <file/dir to watch> <command to execute on file change>"
    exit 1
fi

while true
do
    CONTENT="$(cat $1)"
    sleep $SLEEP
    CONTENT_AGAIN="$(cat $1)"
    if [ "$CONTENT" != "$CONTENT_AGAIN" ]
    then
        clear
        echo "$1 contents changed..."
        echo "Running command $2..."
        eval "$2"

        CONTENT=""
        CONTENT_AGAIN=""
    fi
done
