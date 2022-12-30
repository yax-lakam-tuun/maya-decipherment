#!/usr/bin/python3

####################################################################################################
# ahpula.py  - A script to produce a long count date in the classic notation from given date string
#
# Usage: python3 ahpula.py [DATE]
# 
#        DATE
#           The date has to be given in ISO format (e.g. 2022-12-30).
#           If date is omitted, today's date is used instead.
#
# Sample output: python3 ahpula.py 2022-12-30
#                13.0.10.2.18
####################################################################################################

import datetime
import sys

def digit_weight():
    n = 1
    while True:
        yield n
        n = 18 * n if n == 20 else 20 * n

def maya_number(long_count):
    weight = digit_weight()
    return sum([next(weight) * i for i in long_count])

def long_count_from_maya_number(maya_number):
    weight = digit_weight()
    next_weight = next(weight)
    while maya_number != 0:
        current_weight = next_weight
        next_weight = next(weight)
        lower_part = maya_number % next_weight
        digit = lower_part // current_weight
        maya_number = maya_number - lower_part
        yield digit

def long_count_from_date(date: datetime.datetime):
    poco_uinic_eclipse_long_count = [16, 13, 19, 17, 9]
    poco_uinic_eclipse_date = datetime.datetime(790, 7, 20) # julian date 16 July 790
    poco_uinic_eclipse_maya_number = maya_number(poco_uinic_eclipse_long_count)
    
    delta = (date - poco_uinic_eclipse_date).days
    date_maya_number = poco_uinic_eclipse_maya_number + delta
    return long_count_from_maya_number(date_maya_number)

def long_count_notation(long_count):
    return '.'.join(reversed([str(i) for i in long_count]))

gregorian_date = datetime.datetime.fromisoformat(sys.argv[1]) if len(sys.argv) == 2 else datetime.datetime.now()

long_count = long_count_from_date(gregorian_date)
version_string = long_count_notation(long_count)

print(version_string)
