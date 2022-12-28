#!/bin/bash

find . -name '*.tex' | while read LINE; do chktex -q "$LINE" ; done

