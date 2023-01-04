#!/bin/bash

if [ -z "$1" ]; then
    root_path="."
else
    root_path="$1"
fi

exit_code=0
tex_files=$(find $root_path -type f -name '*.tex')

while read FILE;
do
    short_path="${FILE#$root_path}"
    echo -n "Checking $short_path"
    output=$(chktex -q "$FILE" 2>&1)
    if [ $? -eq 0 ]; then
        echo ".....OK"
    else
        echo ""
        echo "$output"
        exit_code=1
    fi
done  <<< "$tex_files"

if [ $exit_code -ne 0 ]; then
    echo "At least one file check failed. Please see the log."
fi

exit $exit_code