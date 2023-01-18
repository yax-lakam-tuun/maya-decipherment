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
    def __init__(self, maya_number: MayaNumber) -> None:
        self._maya_number = maya_number

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        return LongCountDate(maya_number)

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
    class DayName:
        MAX_ID = 20

        def __init__(self, id: int) -> None:
            if id not in range(self.MAX_ID):
                raise Exception(f"Invalid day name: {id}")
            self._id = id

        def ordinal(self) -> int:
            return 1 + self._id

        def standard(self):
            STANDARD_NAMES = [
                "Imix", "Ik'", "Ak'b'al", "K'an",
                "Chicchan", "Kimi", "Manik'", "Lamat",
                "Muluk", "Ok", "Chuwen", "Eb'",
                "B'en", "Ix", "Men", "Kib'",
                "Kab'an", "Etz'nab'", "Kawak", "Ajaw"
            ]
            return STANDARD_NAMES[self._id]

    IMIX = DayName(0)
    IK = DayName(1)
    AKBAL = DayName(2)
    KAN = DayName(3)
    CHICCHAN = DayName(4)
    KIMI = DayName(5)
    MANIK = DayName(6)
    LAMAT = DayName(7)
    MULUK = DayName(8)
    OK = DayName(9)
    CHUWEN = DayName(10)
    EB = DayName(11)
    BEN = DayName(12)
    IX = DayName(13)
    MEN = DayName(14)
    KIB = DayName(15)
    KABAN = DayName(16)
    ETZNAB = DayName(17)
    KAWAK = DayName(18)
    AJAW = DayName(19)

    TRECENA_DAY_MIN = 1
    TRECENA_DAY_MAX = 13
    TRECENA_DAY_COUNT = TRECENA_DAY_MAX - TRECENA_DAY_MIN + 1
    TOTAL_DAYS = 260
    DAY_NAMES_COUNT = 20

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        base = TzolkinDate.from_trecena_day_name(4, TzolkinDate.AJAW)
        return base + DistanceNumber(maya_number.days)

    @staticmethod
    def from_trecena_day_name(trecena_day: int, day_name: DayName):
        if trecena_day not in range(TzolkinDate.TRECENA_DAY_MIN, TzolkinDate.TRECENA_DAY_MAX+1):
            raise Exception(f"Invalid trecena day: {trecena_day}")
        trecena_day0 = trecena_day - TzolkinDate.TRECENA_DAY_MIN
        day_name0 = day_name.ordinal() - 1
        index = (day_name0 * (-3) * 13 + trecena_day0 * 2 * 20) % 260
        return TzolkinDate(index)

    def __init__(self, index: int) -> None:
        if index not in range(TzolkinDate.TOTAL_DAYS):
            raise Exception(f"Invalid index: {index}")
        self._index = index

    def standard_notation(self):
        return f"{self.trecena_day()} {self.day_name().standard()}"

    def ordinal_day(self) -> int:
        return 1 + self._index

    def trecena_day(self) -> int:
        return TzolkinDate.TRECENA_DAY_MIN + self._index % TzolkinDate.TRECENA_DAY_COUNT

    def day_name(self) -> str:
        return TzolkinDate.DayName(self._index % TzolkinDate.DAY_NAMES_COUNT)

    def __add__(self, other: DistanceNumber):
        new_index = (self._index + other.days) % TzolkinDate.TOTAL_DAYS
        return TzolkinDate(new_index)

class HaabDate:
    class Month:
        MAX_ID = 19

        def __init__(self, id: int) -> None:
            if id not in range(self.MAX_ID):
                raise Exception(f"Invalid month: {id}")
            self._id = id

        def ordinal(self) -> int:
            return 1 + self._id

        def standard(self) -> str:
            MONTHS = [
                "Pop", "Wo'", "Sip", "Sotz'", "Sek", "Xul", "Yaxk'in", "Mol", "Ch'en",
                "Yax", "Sak'", "Keh", "Mak", "K'ank'in", "Muwan", "Pax", "K'ayab'", "Kumk'u", "Wayeb"
            ]
            return MONTHS[self._id]

    POP = Month(0)
    WO = Month(1)
    SIP = Month(2)
    SOTZ = Month(3)
    SEK = Month(4)
    XUL = Month(5)
    YAXKIN = Month(6)
    MOL = Month(7)
    CHEN = Month(8)
    YAX = Month(9)
    SAK = Month(10)
    KEH = Month(11)
    MAK = Month(12)
    KANKIN = Month(13)
    MUWAN = Month(14)
    PAX = Month(15)
    KAYAB = Month(16)
    KUMKU = Month(17)
    WAYEB = Month(18)
    
    WINAL_DAYS = 20
    WAYEB_DAYS = 5
    TOTAL_DAYS = 365

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        base = HaabDate.from_day_month(8, HaabDate.KUMKU)
        return base + DistanceNumber(maya_number.days)

    def from_day_month(day: int, month: Month):
        if day not in range(HaabDate.WAYEB_DAYS if month.ordinal() == 19 else HaabDate.WINAL_DAYS):
            raise Exception(f"Invalid day: {day}")
        day0 = day - 1
        month0 = month.ordinal() - 1
        index = day0 + HaabDate.WINAL_DAYS * month0
        return HaabDate(index)

    def __init__(self, index: int) -> None:
        if index not in range(HaabDate.TOTAL_DAYS):
            raise Exception(f"Invalid index: {index}")
        self._index = index

    def standard_notation(self):
        month_name = self.month().standard()
        return f"End of {month_name}" if self.day() == HaabDate.WINAL_DAYS else f"{self.day()} {month_name}"

    def ordinal_day(self) -> int:
        return 1 + self._index

    def day(self) -> int:
        return 1 + (self._index % HaabDate.WINAL_DAYS)

    def month(self) -> int:
        return HaabDate.Month(self._index // HaabDate.WINAL_DAYS)

    def __add__(self, other: DistanceNumber):
        new_index = (self._index + other.days) % HaabDate.TOTAL_DAYS
        return HaabDate(new_index)


class SupplementarySeries:
    def __init__(self, maya_number: MayaNumber) -> None:
        self.maya_number = maya_number

    @staticmethod
    def from_maya_number(maya_number: MayaNumber):
        return SupplementarySeries(maya_number)

    def underworldGod(self) -> str:
        index = self.maya_number.days % 9
        return f"G{index if index != 0 else 9}"

    def standard_notation(self):
        return self.underworldGod()

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

    parser.add_argument('--supplementary-series', '-s', dest='supplementary_series', action='store_true',
                        default=False, help="print supplementary series")
    parser.add_argument('--mode', choices=['plain', 'json', 'latex'], dest='mode', default='plain')
    return parser.parse_args(args[1:])

class MayaDate:
    def __init__(self, maya_number: MayaNumber) -> None:
        self.maya_number = maya_number
        self.long_count = LongCountDate.from_maya_number(maya_number)
        self.tzolkin = TzolkinDate.from_maya_number(maya_number)
        self.haab = HaabDate.from_maya_number(maya_number)
        self.supplementary_series = SupplementarySeries.from_maya_number(maya_number)

def print_plain(maya: MayaDate, long_count: bool, tzolkin: bool, haab: bool, supplementary_series: bool):
    dates = []

    if long_count:
        dates.append(f"{maya.long_count.standard_notation()}")

    if tzolkin:
        dates.append(f"{maya.tzolkin.standard_notation()}")

    if haab:
        dates.append(f"{maya.haab.standard_notation()}")

    if supplementary_series:
        dates.append(f"{maya.supplementary_series.standard_notation()}")

    print(' '.join(dates))

def print_json(gregorian_date: datetime.datetime, maya_date: MayaDate):
    long_count = maya_date.long_count
    tzolkin = maya_date.tzolkin
    haab = maya_date.haab
    supplementary_series = maya_date.supplementary_series

    json_data = {
        "gregorian-date": gregorian_date.strftime("%Y-%m-%d"),
        "long-count": {
            "standardNotation": long_count.standard_notation(),
            "digits": long_count.digits()
        },
        "tzolkin": {
            "standardNotation": tzolkin.standard_notation(),
            "trecenaDay": tzolkin.trecena_day(),
            "dayName": tzolkin.day_name().standard(),
            "dayNameOrdinal": tzolkin.day_name().ordinal(),
            "ordinalDay": tzolkin.ordinal_day(),
        },
        "haab": {
            "standardNotation": haab.standard_notation(),
            "day": haab.day(),
            "monthName": haab.month().standard(),
            "month": haab.month().ordinal(),
            "ordinalDay": haab.ordinal_day(),
        },
        "supplementary_series": {
            "god-of-the-underworld": supplementary_series.underworldGod()
        }
    }
    print(json.dumps(json_data, indent=4))

def print_latex(gregorian_date: datetime.datetime, maya_date: MayaDate, prefix: str):
    iso_date = gregorian_date.strftime("%Y--%m--%d")
    print(f"\\newcommand{{\{prefix}gregoriandate}}{{{iso_date}\\xspace}}")
    print(f"\\newcommand{{\{prefix}longcount}}{{{maya_date.long_count.standard_notation()}\\xspace}}")
    print(f"\\newcommand{{\{prefix}tzolkin}}{{{maya_date.tzolkin.standard_notation()}\\xspace}}")
    print(f"\\newcommand{{\{prefix}haab}}{{{maya_date.haab.standard_notation()}\\xspace}}")

def main(args):
    settings = parse_arguments(args)
    gregorian_date = datetime.datetime.fromisoformat(settings.date) if settings.date is not None else datetime.datetime.now()
    maya_date = MayaDate(MayaNumber.from_date(gregorian_date))

    if settings.mode == 'plain':
        print_plain(
            maya_date,
            long_count=settings.long_count,
            tzolkin=settings.tzolkin or settings.calendar_round,
            haab=settings.haab or settings.calendar_round,
            supplementary_series=settings.supplementary_series)
    
    if settings.mode == 'json':
        print_json(gregorian_date, maya_date)

    if settings.mode == 'latex':
        print_latex(gregorian_date, maya_date, prefix="documentversion")

if __name__ == '__main__':
    main(sys.argv)