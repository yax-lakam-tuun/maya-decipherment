#!/bin/bash

iso_date=$1

python3 ahpula.py --mode latex $iso_date > document-version.tex