#!/bin/bash

if [ -z "$1" ]; then
    root_path="."
else
    root_path="$1"
fi

script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
chktexrc_path="$script_path/.chktexrc"

exit_code=0
tex_files=$(find $root_path -type f -name '*.tex')

while read FILE;
do
    short_path="${FILE#$root_path}"
    echo -n "Checking $short_path....."
    output=$(chktex -q -l "$chktexrc_path" "$FILE" 2>&1)
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "FAILED"
        echo "$output"
        exit_code=1
    fi
done  <<< "$tex_files"

if [ $exit_code -ne 0 ]; then
    echo "At least one file check failed. Please see the log."
fi

exit $exit_code