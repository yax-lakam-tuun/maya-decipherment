#!/usr/bin/python3

####################################################################################################
# ahpula.py  - A script to produce a long count date in the classic notation from given date string
# type 'python3 ahpula.py --help' for more information
# Sample output: python3 ahpula.py 2022-12-30
#                13.0.10.2.18
# Update document-version.tex: python3 ahpula.py --mode latex > document-version.tex
####################################################################################################

import datetime
import sys
import argparse
import json

class DistanceNumber:
    def __init__(self, days: int) -> None:
        self.days = days

class MayaNumber:
    def __init__(self, days: int) -> None:
        self.days = days

    @staticmethod
    def _digit_weight():
        n = 1
        while True:
            yield n
            n = 360 if n == 20 else 20 * n

    @staticmethod
    def from_date(date: datetime.datetime):
        poco_uinic_eclipse_long_count = [16, 13, 19, 17, 9]
        poco_uinic_eclipse_date = datetime.datetime(790, 7, 20) # julian date 16 July 790
        poco_uinic_eclipse_maya_number = MayaNumber.from_long_count_digits(poco_uinic_eclipse_long_count)
        
        delta = (date - poco_uinic_eclipse_date).days
        return poco_uinic_eclipse_maya_number + DistanceNumber(delta)

    @staticmethod
    def from_long_count_digits(long_count):
        weight = MayaNumber._digit_weight()
        return MayaNumber(sum([next(weight) * i for i in long_count]))

    def long_count_digits(self):
        maya_number = self.days
        weight = MayaNumber._digit_weight()
        next_weight = next(weight)
        while maya_number != 0:
            current_weight = next_weight
            next_weight = next(weight)
            lower_part = maya_number % next_weight
            digit = lower_part // current_weight
            maya_number = maya_number - lower_part
            yield digit

    def __add__(self, other: DistanceNumber):
        return MayaNumber(self.days + other.days)

class LongCountDate:
    def __init__(self) -> None:
        self._maya_number = MayaNumber(0)

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        return LongCountDate() + DistanceNumber(maya_number.days)

    def digits(self):
        ret = [i for i in self._maya_number.long_count_digits()]
        if len(ret) == 0:
            return [0,0,0,0,13]
        if len(ret) < 5:
            ret.extend([0] * (5 - len(ret)))
        return ret

    def standard_notation(self):
        return '.'.join(reversed([str(i) for i in self.digits()]))

    def __add__(self, other: DistanceNumber):
        new_maya_number = self._maya_number + other
        ret = LongCountDate()
        ret._maya_number = new_maya_number
        return ret

class TzolkinDate:
    day_names = [
        "Imix", "Ik'", "Ak'b'al", "K'an",
        "Chicchan", "Kimi", "Manik'", "Lamat",
        "Muluk", "Ok", "Chuwen", "Eb'",
        "B'en", "Ix", "Men", "Kib'",
        "Kab'an", "Etz'nab'", "Kawak", "Ajaw"
    ]

    TRECENA_NUMBER_MIN = 1
    TRECENA_NUMBER_MAX = 13
    TRECENA_NUMBER_COUNT = TRECENA_NUMBER_MAX - TRECENA_NUMBER_MIN + 1
    TOTAL_DAYS = 260

    @staticmethod
    def four_ajaw():
        return TzolkinDate() + DistanceNumber(159)

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        return TzolkinDate.four_ajaw() + DistanceNumber(maya_number.days)

    def __init__(self) -> None:
        self._index = 0 # 1 Imix

    def standard_notation(self):
        return f"{self.trecena_number()} {self.day_name()}"

    def ordinal_day(self) -> int:
        return 1 + self._index

    def trecena_number(self) -> int:
        return TzolkinDate.TRECENA_NUMBER_MIN + self._index % TzolkinDate.TRECENA_NUMBER_COUNT

    def day_name_number(self) -> int:
        return 1 + (self._index % len(TzolkinDate.day_names))

    def day_name(self) -> str:
        return TzolkinDate.day_names[self.day_name_number() - 1]

    def __add__(self, other: DistanceNumber):
        new_index = (self._index + other.days) % TzolkinDate.TOTAL_DAYS
        ret = TzolkinDate()
        ret._index = new_index
        return ret

class HaabDate:
    months = [
        "Pop", "Wo'", "Sip", "Sotz'", "Sek", "Xul", "Yaxk'in", "Mol", "Ch'en",
        "Yax", "Sak'", "Keh", "Mak", "K'ank'in", "Muwan", "Pax", "K'ayab'", "Kumk'u", "Wayeb"
    ]

    WINAL_DAYS = 20
    TOTAL_DAYS = 365

    @staticmethod
    def eight_kumku():
        return HaabDate() + DistanceNumber(347)

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        return HaabDate.eight_kumku() + DistanceNumber(maya_number.days)

    def __init__(self) -> None:
        self._index = 0 # 1 Pop

    def standard_notation(self):
        return f"End of {self.month_name()}" if self.day() == HaabDate.WINAL_DAYS else f"{self.day()} {self.month_name()}"

    def ordinal_day(self) -> int:
        return 1 + self._index

    def day(self) -> int:
        return 1 + (self._index % HaabDate.WINAL_DAYS)

    def month(self) -> int:
        return 1 + self._index // HaabDate.WINAL_DAYS

    def month_name(self) -> int:
        return HaabDate.months[self.month() - 1]

    def __add__(self, other: DistanceNumber):
        new_index = (self._index + other.days) % HaabDate.TOTAL_DAYS
        ret = HaabDate()
        ret._index = new_index
        return ret

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
    parser.add_argument('--mode', choices=['plain', 'json', 'latex'], dest='mode', default='plain')
    return parser.parse_args(args[1:])

class MayaDate:
    def __init__(self, maya_number: MayaNumber) -> None:
        self.maya_number = maya_number
        self.long_count = LongCountDate.from_maya_number(maya_number)
        self.tzolkin = TzolkinDate.from_maya_number(maya_number)
        self.haab = HaabDate.from_maya_number(maya_number)

def print_plain(maya: MayaDate, long_count: bool, tzolkin: bool, haab: bool):
    dates = []

    if long_count:
        dates.append(f"{maya.long_count.standard_notation()}")

    if tzolkin:
        dates.append(f"{maya.tzolkin.standard_notation()}")

    if haab:
        dates.append(f"{maya.haab.standard_notation()}")

    print(' '.join(dates))

def print_json(gregorian_date: datetime.datetime, maya_date: MayaDate):
    json_data = {
        "gregorian-date": gregorian_date.strftime("%Y-%m-%d"),
        "long-count": {
            "standardNotation": maya_date.long_count.standard_notation(),
            "digits": maya_date.long_count.digits()
        },
        "tzolkin": {
            "standardNotation": maya_date.tzolkin.standard_notation(),
            "trecenaNumber": maya_date.tzolkin.trecena_number(),
            "dayName": maya_date.tzolkin.day_name(),
            "dayNameNumber": maya_date.tzolkin.day_name_number(),
            "ordinalDay": maya_date.tzolkin.ordinal_day(),
        },
        "haab": {
            "standardNotation": maya_date.haab.standard_notation(),
            "day": maya_date.haab.day(),
            "monthName": maya_date.haab.month_name(),
            "month": maya_date.haab.month(),
            "ordinalDay": maya_date.haab.ordinal_day(),
        }
    }
    print(json.dumps(json_data, indent=4))

def print_latex(gregorian_date: datetime.datetime, maya_date: MayaDate, prefix: str):
    iso_date = gregorian_date.strftime("%Y--%m--%d")
    print(f"\\newcommand{{\{prefix}gregoriandate}}{{{iso_date}}}")
    print(f"\\newcommand{{\{prefix}longcount}}{{{maya_date.long_count.standard_notation()}}}")
    print(f"\\newcommand{{\{prefix}tzolkin}}{{{maya_date.tzolkin.standard_notation()}}}")
    print(f"\\newcommand{{\{prefix}haab}}{{{maya_date.haab.standard_notation()}}}")

def main(args):
    settings = parse_arguments(args)
    gregorian_date = datetime.datetime.fromisoformat(settings.date) if settings.date is not None else datetime.datetime.now()
    maya_date = MayaDate(MayaNumber.from_date(gregorian_date))

    if settings.mode == 'plain':
        print_plain(
            maya_date,
            long_count=settings.long_count,
            tzolkin=settings.tzolkin or settings.calendar_round,
            haab=settings.haab or settings.calendar_round)
    
    if settings.mode == 'json':
        print_json(gregorian_date, maya_date)

    if settings.mode == 'latex':
        print_latex(gregorian_date, maya_date, prefix="documentversion")

if __name__ == '__main__':
    main(sys.argv)