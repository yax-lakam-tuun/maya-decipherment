#!/usr/bin/env pwsh

[CmdletBinding()]
param (
    [string]
    $IsoDate,

    [switch]
    $CalendarRound,

    [switch]
    $NoLongCount,

    [switch]
    $Tzolkin,

    [switch]
    $Haab,

    [switch]
    $PreferMonthEnding,

    [ValidateSet('Plain', 'Json', 'Latex')]
    [string]
    $Mode = "Plain"
)

function Get-Remainder() {
    [CmdletBinding()]
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
    [CmdletBinding()]
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
    [int] $Index = 0

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

    [int] Ordinal() {
        return 1 + $this.Index
    }

    [TzolkinDate] AddDays([DistanceNumber] $Distance) {
        $NewIndex = Get-Remainder -Number ($this.Index + $Distance.Days) -Divisor $this::DayCount
        return $this::new($NewIndex)
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
    [CmdletBinding()]
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
    static [int] $WinalCount = 19
    static [int] $WinalDayCount = 20
    static [int] $WayebDayCount = 5

    [ValidateRange(0,364)][int] $Index = 0

    HaabDate([int] $Day, [HaabMonth] $Month) {
        if ($Month -eq [HaabMonth]::Wayeb -And $Day -gt $this::WayebDayCount) {
            throw "Wayeb month has only days from 1 to 5"
        }
        if ($Day -gt $this::WinalDayCount) {
            throw "A regular month has only days from 1 to 20"
        }
        $this.Index = $this::WinalDayCount * $Month + ($Day - 1)
    }

    HaabDate([int] $Index) {
        $this.Index = $Index
    }

    [int] Day() {
        return 1 + $(Get-Remainder -Number $this.Index -Divisor $this::WinalDayCount)
    }

    [HaabMonth] Month() {
        return [Math]::Floor($this.Index / $this::WinalDayCount) -as [int]
    }

    [string] StandardNotation([bool] $PreferMonthEnding) {
        $D = $this.Day()
        $M = $this.Month()
        $MaxDays = $M -eq [HaabMonth]::Wayeb ? $this::WayebDayCount : $this::WinalDayCount
        if ($D -eq $MaxDays) {
            if ($PreferMonthEnding -eq $true) {
                return "Ending of " + $(Get-HaabMonthStandardName -Month $M)
            } else {
                $M = Get-Remainder -Number ($M + 1) -Divisor $this::WinalCount
                return "Seating of " + $(Get-HaabMonthStandardName -Month $M)
            }
        } else {
            $DayString = $D -as [string]
            $MonthString = Get-HaabMonthStandardName -Month $M
            return $DayString + " " + $MonthString
        }
    }

    [int] Ordinal() {
        return 1 + $this.Index
    }

    [HaabDate] AddDays([DistanceNumber] $Distance) {
        $NewIndex = Get-Remainder -Number ($this.Index + $Distance.Days) -Divisor $this::DayCount
        return $this::new($NewIndex)
    }
}

function Get-TzolkinDateFrom {
    [CmdletBinding()]
    param (
        [MayaNumber] $MayaNumber
    )

    $BaseDate = [TzolkinDate]::new(4, [TzolkinDayName]::Ajaw)
    return $BaseDate.AddDays($MayaNumber.Days)
}

function Get-HaabDateFrom {
    [CmdletBinding()]
    param (
        [MayaNumber] $MayaNumber
    )

    $BaseDate = [HaabDate]::new(8, [HaabMonth]::Kumku)
    return $BaseDate.AddDays($MayaNumber.Days)
}

class MartinSkidmoreCorrelation {
    static [MayaNumber] MayaNumberFrom([DateTime] $Date) {
        # julian date 16 July 790
        $PocoUinicDate = [DateTime]::ParseExact("0790-07-20", "yyyy-MM-dd", $null)
        $PocoUinicMayaNumber = [LongCountDate]::new((16, 13, 19, 17, 9)).MayaNumber()

        $Delta = New-TimeSpan –Start $PocoUinicDate –End $Date
        return [MayaNumber]::new($PocoUinicMayaNumber.Days + $Delta.Days)
    }
}

function Write-Plain {
    [CmdletBinding()]
    param (
        [MayaDate] $MayaDate,
        [bool] $LongCount = $true,
        [bool] $Tzolkin = $false,
        [bool] $Haab = $false,
        [bool] $PreferMonthEnding = $false
    )

    $Output = @()
    
    if ($LongCount) {
        $Output += $MayaDate.LongCountDate.StandardNotation()
    }

    if ($Tzolkin) {
        $Output += $MayaDate.TzolkinDate.StandardNotation()
    }

    if ($Haab) {
        $Output += $MayaDate.HaabDate.StandardNotation($PreferMonthEnding)
    }

    Write-Output $($Output -join ' ')
}

function Write-Json {
    [CmdletBinding()]
    param (
        [DateTime] $GregorianDate,
        [MayaDate] $MayaDate,
        [bool] $PreferMonthEnding
    )

    $LongCount = [ordered]@{
        standardNotation = $MayaDate.LongCountDate.StandardNotation()
        digits = $MayaDate.LongCountDate.Digits
    }

    $Tzolkin = [ordered]@{
        standardNotation = $MayaDate.TzolkinDate.StandardNotation()
        trecenaDay = $MayaDate.TzolkinDate.TrecenaDay()
        dayName = Get-TzolkinDayStandardName -DayName $MayaDate.TzolkinDate.DayName()
        dayNameOrdinal = $MayaDate.TzolkinDate.DayName() -as [int]
        ordinal = $MayaDate.TzolkinDate.Ordinal()
    }

    $Haab = [ordered]@{
        standardNotation = $MayaDate.HaabDate.StandardNotation($PreferMonthEnding)
        day = $MayaDate.HaabDate.Day()
        monthName = $(Get-HaabMonthStandardName -Month $MayaDate.HaabDate.Month())
        month = $MayaDate.HaabDate.Month() -as [int]
        ordinal = $MayaDate.HaabDate.Ordinal()
    }

    $IsoDate = $(Get-Date $date -Format "yyyy-MM-dd")
    $All = [ordered]@{
        gregorianDate = $IsoDate
        longCountDate = $LongCount
        tzolkin = $Tzolkin
        haab = $Haab
    }
    Write-Output $($All | ConvertTo-Json)
}

function Write-Latex {
    [CmdletBinding()]
    param (
        [DateTime] $GregorianDate,
        [MayaDate] $MayaDate,
        [bool] $PreferMonthEnding,
        [string] $Prefix
    )

    $IsoDate = $(Get-Date $date -Format "yyyy-MM-dd")
    $LongCount = $MayaDate.LongCountDate.StandardNotation()
    $Tzolkin = $MayaDate.TzolkinDate.StandardNotation()
    $Haab = $MayaDate.HaabDate.StandardNotation($PreferMonthEnding)

    Write-Output "\\newcommand{{\$($Prefix)gregoriandate}}{{{$IsoDate}\\xspace}}"
    Write-Output "\\newcommand{{\$($Prefix)longcount}}{{{$LongCount}\\xspace}}"
    Write-Output "\\newcommand{{\$($Prefix)tzolkin}}{{{$Tzolkin}\\xspace}}"
    Write-Output "\\newcommand{{\$($Prefix)haab}}{{{$Haab}\\xspace}}"
}

class MayaDate {
    [MayaNumber] $MayaNumber
    [LongCountDate] $LongCountDate
    [TzolkinDate] $TzolkinDate
    [HaabDate] $HaabDate

    MayaDate([MayaNumber] $MayaNumber) {
        $this.MayaNumber = $MayaNumber
        $this.LongCountDate = [LongCountDate]::new($MayaNumber)
        $this.TzolkinDate = Get-TzolkinDateFrom -MayaNumber $MayaNumber
        $this.HaabDate = Get-HaabDateFrom -MayaNumber $MayaNumber
    }
}

$Date = [DateTime]::ParseExact($IsoDate, "yyyy-MM-dd", $null)
$MayaNumber = [MartinSkidmoreCorrelation]::MayaNumberFrom($Date)
$MayaDate = [MayaDate]::new($MayaNumber)

switch($Mode) {
    "Plain" {
        $Parameters = @{
            MayaDate = $MayaDate
            LongCount = $NoLongCount.IsPresent ? $false : $true
            Tzolkin = $Tzolkin.IsPresent -or $CalendarRound.IsPresent
            Haab = $Haab.IsPresent -or $CalendarRound.IsPresent
            PreferMonthEnding = $PreferMonthEnding.IsPresent
        }
        Write-Plain @Parameters
    }
    "Json" {
        $Parameters = @{
            GregorianDate = $Date
            MayaDate = $MayaDate
            PreferMonthEnding = $PreferMonthEnding.IsPresent
        }
        Write-Json @Parameters
    }
    "Latex" {
        $Parameters = @{
            GregorianDate = $Date
            MayaDate = $MayaDate
            PreferMonthEnding = $PreferMonthEnding.IsPresent
            Prefix = "documentversion"
        }
        Write-Latex @Parameters
    }
}

