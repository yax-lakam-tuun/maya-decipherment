
[CmdletBinding()]
param (
    [string]
    $IsoDate,

    [bool]
    $CalendarRound
)

function Get-Remainder() {
    param (
        [int] $Number,
        [int] $Divisor
    )
    return (($Number % $Divisor) + $Divisor) % $Divisor
}

class DistanceNumber {
    [int] $Days = 0

    DistanceNumber([int] $Days) {
        $this.Days = $Days
    }
}

class MayaNumber {
    [int] $Days = 0

    MayaNumber([int] $Days) {
        $this.Days = $Days
    }
}

class LongCountDate {
    [int[]] $Digits

    LongCountDate([int[]] $Digits) {
        $this.Digits = $Digits
    }

    LongCountDate([MayaNumber] $MayaNumber) {
        $Days = $MayaNumber.Days
        $CurrentWeight = 1
        $NextWeight = 20
        $Result = @()
        
        while($Days -ne 0) {
            $LowerPart = Get-Remainder -Number $Days -Divisor $NextWeight
            $Result += $LowerPart / $CurrentWeight

            $Days = $Days - $LowerPart
            $CurrentWeight = $NextWeight
            $NextWeight = ($NextWeight -eq 20) ? 360 : 20 * $NextWeight
        }
        $this.Digits = $Result
    }

    [string] StandardNotation() {
        $StringDigits = $this.Digits -as [string[]]
        [array]::Reverse($StringDigits)
        return $StringDigits -join "."
    }

    [MayaNumber] MayaNumber() {
        $Weight = 1
        $Sum = 0
        foreach($Digit in $this.Digits) {
            $Sum += $Digit * $Weight
            $Weight = ($Weight -eq 20) ? 360 : 20 * $Weight
        }
        return [MayaNumber]::new($Sum)
    }
}

enum TzolkinDayName {
    Imix
    Ik
    Akbal
    Kan
    Chicchan
    Kimi
    Manik
    Lamat
    Muluk
    Ok
    Chuwen
    Eb
    Ben
    Ix
    Men
    Kib
    Kaban
    Etznab
    Kawak
    Ajaw
}

function Get-TzolkinDayStandardName() {
    param (
        [TzolkinDayName] $DayName
    )

    $StandardNames = (
        "Imix", "Ik'", "Ak'b'al", "K'an",
        "Chicchan", "Kimi", "Manik'", "Lamat",
        "Muluk", "Ok", "Chuwen", "Eb'",
        "B'en", "Ix", "Men", "Kib'",
        "Kab'an", "Etz'nab'", "Kawak", "Ajaw"
    )
    return $StandardNames[$DayName]
}

class TzolkinDate {
    static [int] $DayCount = 260
    static [int] $DayNameCount = 20
    static [int] $TrecenaDayCount = 13
    static [int] $TrecenaDayMin = 1
    static [int] $TrecenaDayMax = 13

    [ValidateRange(0, 259)]
    hidden [int] $Index = 0

    TzolkinDate([int] $TrecenaDay, [TzolkinDayName] $DayName) {
        $X = $DayName * (-3) * $this::TrecenaDayCount + 
             ($TrecenaDay - $this::TrecenaDayMin) * 2 * $this::DayNameCount
        $this.Index = $(Get-Remainder -Number $X -Divisor $this::DayCount)
    }

    TzolkinDate([int] $Index) {
        $this.Index = $Index
    }

    [int] TrecenaDay() {
        $Day0 = Get-Remainder -Number $this.Index -Divisor $this::TrecenaDayCount
        return $this::TrecenaDayMin + $Day0
    }

    [TzolkinDayName] DayName() {
        return Get-Remainder -Number $this.Index -Divisor $this::DayNameCount
    }

    [string] StandardNotation() {
        $TrecendaDayString = $this.TrecenaDay() -as [string]
        $DayNameString = Get-TzolkinDayStandardName -DayName $this.DayName()
        return $TrecendaDayString + " " + $DayNameString
    }

    [int] OrdinalDay() {
        return 1 + $this.Index
    }

    [TzolkinDate] AddDays([int] $Days) {
        return $this::new($(Get-Remainder -Number ($this.Index + $Days) -Divisor $this::DayCount))
    }
}

enum HaabMonth {
    Pop
    Wo
    Sip
    Sotz
    Sek
    Xul
    Yaxkin
    Mol
    Chen
    Yax
    Sak
    Keh
    Mak
    Kankin
    Muwan
    Pax
    Kayab
    Kumku
    Wayeb
}

function Get-HaabMonthStandardName()
{
    param (
        [HaabMonth] $Month
    )

    $Months = (
        "Pop", "Wo'", "Sip", "Sotz'", "Sek", "Xul", "Yaxk'in", "Mol", "Ch'en",
        "Yax", "Sak'", "Keh", "Mak", "K'ank'in", "Muwan", "Pax", "K'ayab'", "Kumk'u", "Wayeb"
    )
    return $Months[$Month]
}

class HaabDate {
    static [int] $DayCount = 365
    static [int] $WinalDayCount = 20
    static [int] $WayebDayCount = 5

    [ValidateRange(0,364)][int] $Index = 0

    HaabDate([int] $Day, [HaabMonth] $Month) {
        if ($Month -eq [HaabMonth]::Wayeb -And $Day -ge $this::WayebDayCount) {
            throw "Wayeb month has only days from 0 to 4"
        }
        $this.Index = $this::WinalDayCount * $Month + $Day
    }

    HaabDate([int] $Index) {
        $this.Index = $Index
    }

    [int] Day() {
        return $this.Index / $this::WinalDayCount
    }

    [HaabMonth] Month() {
        return Get-Remainder -Number $this.Index -Divisor $this::WinalDayCount
    }

    [string] StandardNotation() {
        $DayString = $this.Day() -as [string]
        $MonthString = Get-HaabMonthStandardName -Month $this.Month()
        return $DayString + " " + $MonthString
    }

    [int] OrdinalDay() {
        return 1 + $this.Index
    }

    [HaabDate] AddDays([int] $Days) {
        $Ordinal0 = Get-Remainder -Number ($this.OrdinalDay() - 1 + $Days) -Divisor $this::DayCount
        $Day0 = Get-Remainder -Number $Ordinal0 -Divisor $this::WinalDayCount
        $Month0 = $Ordinal0 / $this::WinalDayCount
        return [HaabDate]::new($Day0, $Month0 -as [HaabMonth])
    }
}

$PocoUinicDate = [DateTime]::ParseExact("0790-07-20", "yyyy-MM-dd", $null) # julian date 16 July 790
$Date = [DateTime]::ParseExact($IsoDate, "yyyy-MM-dd", $null)
$Delta = New-TimeSpan –Start $PocoUinicDate –End $Date
Write-Output $Delta

$lc = [LongCountDate]::new((16, 13, 19, 17, 9))
$lc = [LongCountDate]::new([MayaNumber]::new(1412618))
Write-Output $lc.StandardNotation()
Write-Output $lc.MayaNumber()

Write-Output $(Get-TzolkinDayStandardName([TzolkinDayName]::Chuwen))
Write-Output $(Get-HaabMonthStandardName([HaabMonth]::Kumku))

$t = [TzolkinDate]::new(1, [TzolkinDayName]::Ajaw).AddDays(19)
#$t = [TzolkinDate]::new(1, [TzolkinDayName]::Imix)
Write-Output $t
Write-Output $t.OrdinalDay()
Write-Output $t.StandardNotation()

$h = [HaabDate]::new(4, [HaabMonth]::Wayeb);
Write-Output $h
Write-Output $h.OrdinalDay()
Write-Output $h.StandardNotation()

$h = [HaabDate]::new(17, [HaabMonth]::Muwan).AddDays(3);
Write-Output $h
Write-Output $h.OrdinalDay()
Write-Output $h.StandardNotation()

#poco_uinic_eclipse_long_count = [16, 13, 19, 17, 9]
#poco_uinic_eclipse_date = datetime.datetime(790, 7, 20) # julian date 16 July 790
#poco_uinic_eclipse_maya_number = MayaNumber.from_long_count_digits(poco_uinic_eclipse_long_count)
