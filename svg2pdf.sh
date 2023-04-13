#!/bin/bash

files=($@)

if [ ${#files[@]} -eq 0 ]; then
    files=$(find . -type f -name "*.svg")
fi

for i in ${files};
do
    out="${i//svg/pdf}"
    inkscape --export-area-drawing --without-gui --file=${i} --export-pdf=${out} --export-dpi=100
done
