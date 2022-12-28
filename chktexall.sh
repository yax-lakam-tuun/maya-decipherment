#!/bin/bash

find . -name '*.tex' | while read LINE; 
do 
    echo "Checking $LINE"
    chktex -q "$LINE" 
done

