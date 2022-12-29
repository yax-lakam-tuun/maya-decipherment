#!/bin/bash

root_path=$1

find $root_path -name '*.tex' | while read LINE; 
do 
    echo "Checking $LINE"
    chktex -q "$LINE" 
done

