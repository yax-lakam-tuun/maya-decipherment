#!/bin/bash

if [ -z "$1" ]; then
    iso_date=$(date -I)
else
    iso_date="$1"
fi

python3 ahpula.py --mode latex $iso_date > document-version.tex
