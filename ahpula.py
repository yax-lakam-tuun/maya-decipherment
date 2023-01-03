#!/usr/bin/python3

####################################################################################################
# ahpula.py  - A script to produce a long count date in the classic notation from given date string
#
# usage: ahpula.py [-h] [--long-count | --no-long-count] [--tzolkin | --no-tzolkin] [--haab | --no-haab] [date]
# 
# Ahpula Maya date script
# 
# positional arguments:
#   date                  date in ISO format (YYYY-MM-DD)
# 
# options:
#   -h, --help            show this help message and exit
#   --long-count, --no-long-count
#                         print Long count date (default: True)
#   --tzolkin, --no-tzolkin
#                         print Tzolk'in date (default: False)
#   --haab, --no-haab     print Haab' date (default: False)
#
# Sample output: python3 ahpula.py 2022-12-30
#                13.0.10.2.18
####################################################################################################

import datetime
import sys
import argparse

def digit_weight():
    n = 1
    while True:
        yield n
        n = 18 * n if n == 20 else 20 * n

def maya_number(long_count):
    weight = digit_weight()
    return sum([next(weight) * i for i in long_count])

def long_count_from_maya_number(maya_number: int):
    weight = digit_weight()
    next_weight = next(weight)
    while maya_number != 0:
        current_weight = next_weight
        next_weight = next(weight)
        lower_part = maya_number % next_weight
        digit = lower_part // current_weight
        maya_number = maya_number - lower_part
        yield digit

def maya_number_from_date(date: datetime.datetime):
    poco_uinic_eclipse_long_count = [16, 13, 19, 17, 9]
    poco_uinic_eclipse_date = datetime.datetime(790, 7, 20) # julian date 16 July 790
    poco_uinic_eclipse_maya_number = maya_number(poco_uinic_eclipse_long_count)
    
    delta = (date - poco_uinic_eclipse_date).days
    return poco_uinic_eclipse_maya_number + delta

def long_count_notation(long_count):
    return '.'.join(reversed([str(i) for i in long_count]))    

def tzolkin_date_from_maya_number(maya_number: int):
    days = [
        "Imix", "Ik'", "Ak'b'al", "K'an",
        "Chicchan", "Kimi", "Manik'", "Lamat",
        "Muluk", "Ok", "Chuwen", "Eb'",
        "B'en", "Ix", "Men", "Kib'",
        "Kab'an", "Etz'nab'", "Kawak", "Ajaw"
    ]
    number_count = 13
    base_day = 4   # 4
    base_name_index = 19 # Ajaw
    return 1 + ((base_day - 1 + maya_number) % number_count), days[(base_name_index + maya_number) % len(days)]

def haab_date_from_maya_number(maya_number: int):
    months = [
        "Pop", "Wo'", "Sip", "Sotz'", "Sek", "Xul", "Yaxk'in", "Mol", "Ch'en",
        "Yax", "Sak'", "Keh", "Mak", "K'ank'in", "Muwan", "Pax", "K'ayab'", "Kumk'u", "Wayeb"
    ]
    day_count = 20
    base = 348 # 8 Kumk'u
    day_number = (base + maya_number) % 365
    return day_number % day_count, months[day_number // day_count]

def parse_arguments(args):
    parser = argparse.ArgumentParser(description='Ahpula Maya date script')
    parser.add_argument('date', nargs='?', help="date in ISO format (YYYY-MM-DD)")
    parser.add_argument('--long-count', dest='long_count', action=argparse.BooleanOptionalAction,
                        default=True, help="print Long count date")
    parser.add_argument('--tzolkin', dest='tzolkin', action=argparse.BooleanOptionalAction,
                        default=False, help="print Tzolk'in date")
    parser.add_argument('--haab', dest='haab', action=argparse.BooleanOptionalAction,
                        default=False, help="print Haab' date")
    parser.add_argument('--calendar-round', '-cr', dest='calendar_round', action='store_true',
                        default=False, help="print calendar round")
    return parser.parse_args(args[1:])


def main(args):
    settings = parse_arguments(args)
    gregorian_date = datetime.datetime.fromisoformat(settings.date) if settings.date is not None else datetime.datetime.now()

    maya_number = maya_number_from_date(gregorian_date)
    long_count = long_count_from_maya_number(maya_number)

    dates = []

    if settings.long_count:
        dates.append(f"{long_count_notation(long_count)}")

    if settings.tzolkin or settings.calendar_round:
        number, day = tzolkin_date_from_maya_number(maya_number)
        dates.append(f"{number} {day}")

    if settings.haab or settings.calendar_round:
        day, month = haab_date_from_maya_number(maya_number)
        dates.append(f"{day} {month}")

    print(' '.join(dates))


if __name__ == '__main__':
    main(sys.argv)