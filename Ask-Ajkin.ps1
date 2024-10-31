#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Procudes Maya calendar date information from a given Gregorian date.

    .DESCRIPTION
    Produce a long count date in the classic notation from given date string.
    The output format can be controlled by the Mode parameter.

    Plain:
        Standard scientific notation, e.g. 10.9.15.15.9 4 Muluk 2 Yaxk'in

    Json:
        All information will be written in Json format.
        It always includes everthing regardless of the switches Tzolkin, Haab, 
        CalendarRound and LongCount.

    Latex:
        Long count, Tzolk'in and Haab information will be written in a Latex readable format.

    .INPUTS
    None. You cannot pipe objects into this script.

    .OUTPUTS
    Long count date, Haab date and/or Tzolk'in date in either plain text, Json or Latex format.

    .EXAMPLE
    ./Ask-Ajkin.ps1 -GregorianDate 2022-12-30 -CalendarRound -Plain

    9 Etz'nab' 11 K'ank'in

    .EXAMPLE
    ./Ask-Ajkin.ps1 -GregorianDate 2023-04-03 -LongCount -CalendarRound -PreferMonthEnding -Plain

    13.0.10.7.12 12 Eb' Ending of Wayeb

    .LINK
    https://github.com/yax-lakam-tuun/maya-decipherment
#>
[CmdletBinding(DefaultParametersetName="default")]
param (
    [ValidatePattern("^\d{4}-\d{2}-\d{2}$")]
    [AllowNull()]
    [string]
    # Gregorian date in ISO format. Current date is used when parameter is omitted.
    $GregorianDate = $null,

    [ValidatePattern("^\d{1,2}.\d{1,2}.\d{1,2}.\d{1,2}.\d{1,2}$")]
    [AllowNull()]
    [string]
    # Long count. 5 digits separated by dots.
    $LongCountDate = $null,

    [Parameter(ParameterSetName="PlainSet")]
    [switch]
    # Include Tzolk'in and Haab date in plain mode
    $CalendarRound,

    [Parameter(ParameterSetName="PlainSet")]
    [switch]
    # Include Long Count date in plain mode
    $LongCount,

    [Parameter(ParameterSetName="PlainSet")]
    [switch]
    # Include Tzolk'in date in plain mode
    $Tzolkin,

    [Parameter(ParameterSetName="PlainSet")]
    [switch]
    # Include Haab date in plain mode
    $Haab,

    [Parameter(ParameterSetName="PlainSet")]
    [Parameter(ParameterSetName="JsonSet")]
    [switch]
    # The transition between two months is written as "Ending" instead of "Seating"
    $PreferMonthEnding = $false,

    [Parameter(ParameterSetName="PlainSet")]
    [Parameter(ParameterSetName="JsonSet")]
    [switch]
    # Show gregorian date in brackets
    $IncludeGregorianDate = $false,

    [Parameter(ParameterSetName="PlainSet")]
    [switch]
    # Use plain mode
    $Plain = $false,

    [Parameter(ParameterSetName="JsonSet")]
    [switch]
    # Use json mode
    $Json = $false,

    [Parameter(ParameterSetName="LatexSet")]
    [switch]
    # Use json mode
    $Latex = $false
)

class Private {
    static [int] GetRemainder([int] $Number, [int] $Divisor) {
        return (($Number % $Divisor) + $Divisor) % $Divisor
    }
}

class DistanceNumber {
    [int] $Days = 0

    DistanceNumber([int] $Days) {
        $this.Days = $Days
    }
}

#A = Y/100
#B = A/4
#C = 2-A+B
#E = 365.25x(Y+4716)
#F = 30.6001x(M+1)
#JD= C+D+E+F-1524.5

class JulianDay {
    [int] $Days = 0

    JulianDay([int] $Days) {
        $this.Days = $Days
    }

    static [JulianDay] FromIsoDate([string] $IsoDate) {
        $IsoDate -match "^(?<Year>-*\d{4})-(?<Month>\d{2})-(?<Day>\d{2})$"
        $Day = ($Matches.Day -as [float]) + 0.5
        $Month = $Matches.Month -as [int]
        $Year = $Matches.Year -as [int]

        if ($Month -le 2) {
            $Year = $Year - 1
            $Month = $Month + 12
        }

        $B = 2 - [Math]::Floor($Year / 100) + [Math]::Floor($Year / 400)
        $Number = [Math]::Floor(365.25*($Year+4716)) + [Math]::Floor(30.6001*($Month+1)) + $Day + $B - 1524.5
        return [JulianDay]::new($Number)
    }
}

class MayanDay {
    [int] $Days = 0

    MayanDay([int] $Days) {
        $this.Days = $Days
    }
}

class LongCountDate {
    [int[]] $Digits

    LongCountDate([int[]] $Digits) {
        if ($Digits.Length -lt 5) {
            throw "A Long Count date consists of at least 5 digits"
        }
        if ($Digits[1] -lt 0 -or $Digits[1] -gt 17) {
            throw "A Long Count Winal digit may range from 0 to 17 only"
        }
        foreach($Digit in $Digits) {
            if ($Digit -lt 0 -or $Digit -gt 19) {
                throw "A Long Count digit may range from 0 to 19 only"
            }
        }
        $this.Digits = $Digits
    }

    static [LongCountDate] DateFrom([MayanDay] $MayanDay) {
        $Days = $MayanDay.Days
        $CurrentWeight = 1
        $NextWeight = 20
        $Result = @()
        
        while($Days -ne 0) {
            $LowerPart = [Private]::GetRemainder($Days, $NextWeight)
            $Result += $LowerPart / $CurrentWeight

            $Days = $Days - $LowerPart
            $CurrentWeight = $NextWeight
            $NextWeight = ($NextWeight -eq 20) ? 360 : 20 * $NextWeight
        }

        if ($Result.Length -lt 5) {
            $Result += (0..(5 - $Result.Length - 1)) | ForEach-Object 0
        }
        return [LongCountDate]::new($Result)
    }

    [string] StandardNotation() {
        $StringDigits = $this.Digits -as [string[]]
        [array]::Reverse($StringDigits)
        return $StringDigits -join "."
    }

    [MayanDay] MayanDay() {
        $Weight = 1
        $Sum = 0
        foreach($Digit in $this.Digits) {
            $Sum += $Digit * $Weight
            $Weight = ($Weight -eq 20) ? 360 : 20 * $Weight
        }
        return [MayanDay]::new($Sum)
    }

    static [LongCountDate] ParseExact([string] $StandardNotation) {
        $Parts = $StandardNotation.Split('.')
        [int[]]$ParsedDigits = foreach($Part in $Parts) {
            [int]::parse($Part)
        }
        [array]::Reverse($ParsedDigits)
        return [LongCountDate]::new($ParsedDigits)
    }
}

class TzolkinDayName {
    [ValidateRange(0,19)][int] $Index = 0

    TzolkinDayName($Index) {
        $this.Index = $Index
    }

    static [string[]] $StandardNames = (
        "Imix", "Ik'", "Ak'b'al", "K'an",
        "Chicchan", "Kimi", "Manik'", "Lamat",
        "Muluk", "Ok", "Chuwen", "Eb'",
        "B'en", "Ix", "Men", "Kib'",
        "Kab'an", "Etz'nab'", "Kawak", "Ajaw"
    )

    [string] StandardName() {
        return $this::StandardNames[$this.Index]
    }

    [string] ToString() {
        return $this::StandardNames[$this.Index]
    }

    static [TzolkinDayName] $Imix = [TzolkinDayName]::new(0)
    static [TzolkinDayName] $Ik = [TzolkinDayName]::new(1)
    static [TzolkinDayName] $Akbal = [TzolkinDayName]::new(2)
    static [TzolkinDayName] $Kan = [TzolkinDayName]::new(3)
    static [TzolkinDayName] $Chicchan = [TzolkinDayName]::new(4)
    static [TzolkinDayName] $Kimi = [TzolkinDayName]::new(5)
    static [TzolkinDayName] $Manik = [TzolkinDayName]::new(6)
    static [TzolkinDayName] $Lamat = [TzolkinDayName]::new(7)
    static [TzolkinDayName] $Muluk = [TzolkinDayName]::new(8)
    static [TzolkinDayName] $Ok = [TzolkinDayName]::new(9)
    static [TzolkinDayName] $Chuwen = [TzolkinDayName]::new(10)
    static [TzolkinDayName] $Eb = [TzolkinDayName]::new(11)
    static [TzolkinDayName] $Ben = [TzolkinDayName]::new(12)
    static [TzolkinDayName] $Ix = [TzolkinDayName]::new(13)
    static [TzolkinDayName] $Men = [TzolkinDayName]::new(14)
    static [TzolkinDayName] $Kib = [TzolkinDayName]::new(15)
    static [TzolkinDayName] $Kaban = [TzolkinDayName]::new(16)
    static [TzolkinDayName] $Etznab = [TzolkinDayName]::new(17)
    static [TzolkinDayName] $Kawak = [TzolkinDayName]::new(18)
    static [TzolkinDayName] $Ajaw = [TzolkinDayName]::new(19)
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
        if ($TrecenaDay -lt $this::TrecenaDayMin -or $TrecenaDay -gt $this::TrecenaDayMax) {
            throw "A trecena has only days from 1 to 13 "
        }

        $X = $DayName.Index * (-3) * $this::TrecenaDayCount + 
             ($TrecenaDay - $this::TrecenaDayMin) * 2 * $this::DayNameCount
        $this.Index = [Private]::GetRemainder($X, $this::DayCount)
    }

    TzolkinDate([int] $Index) {
        $this.Index = $Index
    }

    static [TzolkinDate] DateFrom([MayanDay] $MayanDay) {
    
        $BaseDate = [TzolkinDate]::new(4, [TzolkinDayName]::Ajaw)
        return $BaseDate.AddDays($MayanDay.Days)
    }

    [int] TrecenaDay() {
        $Day0 = [Private]::GetRemainder($this.Index, $this::TrecenaDayCount)
        return $this::TrecenaDayMin + $Day0
    }

    [TzolkinDayName] DayName() {
        return [TzolkinDayName]::new([Private]::GetRemainder($this.Index , $this::DayNameCount))
    }

    [string] StandardNotation() {
        $TrecendaDayString = $this.TrecenaDay() -as [string]
        $DayNameString = $this.DayName().StandardName()
        return $TrecendaDayString + " " + $DayNameString
    }

    [int] Ordinal() {
        return 1 + $this.Index
    }

    [TzolkinDate] AddDays([DistanceNumber] $Distance) {
        $NewIndex = [Private]::GetRemainder(($this.Index + $Distance.Days), $this::DayCount)
        return $this::new($NewIndex)
    }
}

class HaabMonth : System.IEquatable[Object] {
    [ValidateRange(0,18)][int] $Index = 0

    HaabMonth($Index) {
        $this.Index = $Index
    }

    static [string[]] $StandardNames = (
        "Pop", "Wo'", "Sip", "Sotz'", "Sek", "Xul", "Yaxk'in", "Mol", "Ch'en",
        "Yax", "Sak'", "Keh", "Mak", "K'ank'in", "Muwan", "Pax", "K'ayab'", "Kumk'u", "Wayeb"
    )

    [string] StandardName() {
        
        return $this::StandardNames[$this.Index]
    }

    [string] ToString() {
        return $this::StandardNames[$this.Index]
    }

    [bool] Equals([Object] $Other) {
        $OtherMonth = $Other -as [HaabMonth]
        if ($OtherMonth) {
            return $this.Index -eq $OtherMonth.Index
        }
        return $false
    }

    static [HaabMonth] $Pop = [HaabMonth]::new(0)
    static [HaabMonth] $Wo = [HaabMonth]::new(1)
    static [HaabMonth] $Sip = [HaabMonth]::new(2)
    static [HaabMonth] $Sotz = [HaabMonth]::new(3)
    static [HaabMonth] $Sek = [HaabMonth]::new(4)
    static [HaabMonth] $Xul = [HaabMonth]::new(5)
    static [HaabMonth] $Yaxkin = [HaabMonth]::new(6)
    static [HaabMonth] $Mol = [HaabMonth]::new(7)
    static [HaabMonth] $Chen = [HaabMonth]::new(8)
    static [HaabMonth] $Yax = [HaabMonth]::new(9)
    static [HaabMonth] $Sak = [HaabMonth]::new(10)
    static [HaabMonth] $Keh = [HaabMonth]::new(11)
    static [HaabMonth] $Mak = [HaabMonth]::new(12)
    static [HaabMonth] $Kankin = [HaabMonth]::new(13)
    static [HaabMonth] $Muwan = [HaabMonth]::new(14)
    static [HaabMonth] $Pax = [HaabMonth]::new(15)
    static [HaabMonth] $Kayab = [HaabMonth]::new(16)
    static [HaabMonth] $Kumku = [HaabMonth]::new(17)
    static [HaabMonth] $Wayeb = [HaabMonth]::new(18)
}

class HaabDate {
    static [int] $DayCount = 365
    static [int] $WinalCount = 19
    static [int] $WinalDayCount = 20
    static [int] $WayebDayCount = 5

    [ValidateRange(0,364)][int] $Index = 0

    HaabDate([int] $Day, [HaabMonth] $Month) {
        if ($Month -eq [HaabMonth]::Wayeb -and $Day -gt $this::WayebDayCount) {
            throw "Wayeb month has only days from 1 to 5"
        }
        if ($Day -gt $this::WinalDayCount) {
            throw "A regular month has only days from 1 to 20"
        }
        $this.Index = $this::WinalDayCount * $Month.Index + ($Day - 1)
    }

    HaabDate([int] $Index) {
        $this.Index = $Index
    }

    static [HaabDate] DateFrom([MayanDay] $MayanDay) {
        $BaseDate = [HaabDate]::new(8, [HaabMonth]::Kumku)
        return $BaseDate.AddDays($MayanDay.Days)
    }

    [int] Day() {
        return 1 + [Private]::GetRemainder($this.Index, $this::WinalDayCount)
    }

    [HaabMonth] Month() {
        return [Math]::Floor($this.Index / $this::WinalDayCount) -as [HaabMonth]
    }

    [string] StandardNotation([bool] $PreferMonthEnding) {
        $D = $this.Day()
        $M = $this.Month()
        $MaxDays = if ($M -eq [HaabMonth]::Wayeb) { $this::WayebDayCount } else { $this::WinalDayCount }
        if ($D -eq $MaxDays) {
            if ($PreferMonthEnding -eq $true) {
                return "Ending of " + $M.StandardName()
            } else {
                $M = [HaabMonth]::new([Private]::GetRemainder(($M.Index + 1), $this::WinalCount))
                return "Seating of " + $M.StandardName()
            }
        } else {
            return $D.ToString() + " " + $M.StandardName()
        }
    }

    [int] Ordinal() {
        return 1 + $this.Index
    }

    [HaabDate] AddDays([DistanceNumber] $Distance) {
        $NewIndex = [Private]::GetRemainder(($this.Index + $Distance.Days), $this::DayCount)
        return $this::new($NewIndex)
    }
}

class MartinSkidmoreCorrelation {
    # julian date 16 July 790
    static [DateTime] $PocoUinicDate = [DateTime]::ParseExact("0790-07-20", "yyyy-MM-dd", $null)
    static [MayanDay] $PocoUinicMayanDay = [LongCountDate]::new((16, 13, 19, 17, 9)).MayanDay()

    static [DateTime] GregorianDateFrom([LongCountDate] $Date) {
        $BaseDate = [MartinSkidmoreCorrelation]::PocoUinicDate
        $BaseDay = [MartinSkidmoreCorrelation]::PocoUinicMayanDay
        $Delta = $Date.MayanDay().Days - $BaseDay.Days
        return $BaseDate.AddDays($Delta)
    }

    static [MayanDay] MayanDayFrom([DateTime] $Date) {
        $BaseDate = [MartinSkidmoreCorrelation]::PocoUinicDate
        $BaseDay = [MartinSkidmoreCorrelation]::PocoUinicMayanDay
        $Delta = New-TimeSpan –Start $BaseDate –End $Date
        return [MayanDay]::new($BaseDay.Days + $Delta.Days)
    }
}

class MayaDate : System.IFormattable {
    [MayanDay] $MayanDay
    [LongCountDate] $LongCountDate
    [TzolkinDate] $TzolkinDate
    [HaabDate] $HaabDate

    MayaDate([MayanDay] $MayanDay) {
        $this.MayanDay = $MayanDay
        $this.LongCountDate = [LongCountDate]::DateFrom($MayanDay)
        $this.TzolkinDate = [TzolkinDate]::DateFrom($MayanDay)
        $this.HaabDate = [HaabDate]::DateFrom($MayanDay)
    }

    [String] ToString([String] $Format, [System.IFormatProvider] $FormatProvider) {
        $PreferMonthEnding = $false
        $Output = @()
        $Output += $this.LongCountDate.StandardNotation()
        $Output += $this.TzolkinDate.StandardNotation()
        $Output += $this.HaabDate.StandardNotation($PreferMonthEnding)
        return $Output -join ' '
    }

    [String] ToString([String] $Format) {
        return $this.ToString($Format, $null)
    }
    
    [String] ToString() {
        return $this.ToString($null, $null)
    }
}

function Get-Plain {
    [CmdletBinding()]
    param (
        [DateTime] $GregorianDate,
        [MayaDate] $MayaDate,
        [bool] $LongCount,
        [bool] $Tzolkin,
        [bool] $Haab,
        [bool] $PreferMonthEnding,
        [bool] $IncludeGregorianDate
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

    if ($IncludeGregorianDate) {
        $Output += "(" + $(Get-Date -Date $GregorianDate -UFormat "%F") + ")"
    }

    return $Output -join ' '
}

function Get-Json {
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
        dayName = $MayaDate.TzolkinDate.DayName().StandardName()
        dayNameOrdinal = $MayaDate.TzolkinDate.DayName().Index
        ordinal = $MayaDate.TzolkinDate.Ordinal()
    }

    $Haab = [ordered]@{
        standardNotation = $MayaDate.HaabDate.StandardNotation($PreferMonthEnding)
        day = $MayaDate.HaabDate.Day()
        monthName = $MayaDate.HaabDate.Month().StandardName()
        month = $MayaDate.HaabDate.Month().Index
        ordinal = $MayaDate.HaabDate.Ordinal()
    }

    $GregorianDate = $(Get-Date $date -Format "yyyy-MM-dd")
    $All = [ordered]@{
        gregorianDate = $GregorianDate
        longCountDate = $LongCount
        tzolkin = $Tzolkin
        haab = $Haab
    }
    return $All | ConvertTo-Json
}

function Get-Latex {
    [CmdletBinding()]
    param (
        [DateTime] $GregorianDate,
        [MayaDate] $MayaDate,
        [bool] $PreferMonthEnding,
        [string] $Prefix
    )

    $LatexGregorianDate = $(Get-Date $date -Format "yyyy--MM--dd")
    $LongCount = $MayaDate.LongCountDate.StandardNotation()
    $Tzolkin = $MayaDate.TzolkinDate.StandardNotation()
    $Haab = $MayaDate.HaabDate.StandardNotation($PreferMonthEnding)

    $Lines = @(
        "\newcommand{\$($Prefix)gregoriandate}{$LatexGregorianDate\xspace}",
        "\newcommand{\$($Prefix)longcount}{$LongCount\xspace}",
        "\newcommand{\$($Prefix)tzolkin}{$Tzolkin\xspace}",
        "\newcommand{\$($Prefix)haab}{$Haab\xspace}"
    )

    return $Lines -join "`n"
}

function Main {
    [CmdletBinding()]
    param (
        [string] $GregorianDate,
        [string] $LongCountDate,
        [switch] $CalendarRound,
        [switch] $LongCount,
        [switch] $Tzolkin,
        [switch] $Haab,
        [switch] $PreferMonthEnding,
        [switch] $IncludeGregorianDate,
        [switch] $Plain,
        [switch] $Json,
        [switch] $Latex
    )

    if ($GregorianDate -and $LongCountDate) {
        throw "Please specify only one date, either a Gregorian date or a Long Count date"
    }

    if (-not $GregorianDate -and -not $LongCountDate) {
        $GregorianDate = $(Get-Date -Format "yyyy-MM-dd")
    }

    $Correlation = [MartinSkidmoreCorrelation]

    if ($GregorianDate) {
        $Date = [DateTime]::ParseExact($GregorianDate, "yyyy-MM-dd", $null)
        $MayanDay = $Correlation::MayanDayFrom($Date)
    } else {
        $LC = [LongCountDate]::ParseExact($LongCountDate)
        $Date = $Correlation::GregorianDateFrom($LC)
        $MayanDay = $LC.MayanDay()
    }

    $MayaDate = [MayaDate]::new($MayanDay)

    if ($Plain) {
        if (-not $LongCount -and -not $Tzolkin -and -not $Haab -and -not $CalendarRound) {
            $LongCount = $true
            $CalendarRound = $true
        }
        $Parameters = @{
            GregorianDate = $Date
            MayaDate = $MayaDate
            LongCount = $LongCount
            Tzolkin = $Tzolkin -or $CalendarRound
            Haab = $Haab -or $CalendarRound
            PreferMonthEnding = $PreferMonthEnding
            IncludeGregorianDate = $IncludeGregorianDate
        }
        return Get-Plain @Parameters
    }

    if ($Json) {
        $Parameters = @{
            GregorianDate = $Date
            MayaDate = $MayaDate
            PreferMonthEnding = $PreferMonthEnding
        }
        return Get-Json @Parameters
    }

    if ($Latex) {
        $Parameters = @{
            GregorianDate = $Date
            MayaDate = $MayaDate
            PreferMonthEnding = $PreferMonthEnding
            Prefix = "documentversion"
        }
        return Get-Latex @Parameters
    }

    return $MayaDate
}

function Assert {
    [CmdletBinding()]
    param (
        [string] $Statement,
        $Expected
    )

    $Actual = $($Statement)

    if ($Actual -eq $($Expected)) {
        return
    }

    $Actual = $Actual.ToString()
    $Expected = $Expected.ToString()

    Write-Warning "Test failed."
    Write-Warning "Actual:   $Actual"
    Write-Warning "Expected: $Expected"
    Write-Error "Test failed"
    Exit 1
}

function Test-LongCountDate {
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(0)).StandardNotation()) -Expected "0.0.0.0.0"
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(1)).StandardNotation()) -Expected "0.0.0.0.1"
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(19)).StandardNotation()) -Expected "0.0.0.0.19"
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(20)).StandardNotation()) -Expected "0.0.0.1.0"
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(359)).StandardNotation()) -Expected "0.0.0.17.19"
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(360)).StandardNotation()) -Expected "0.0.1.0.0"
    Assert -Statement ([LongCountDate]::DateFrom([MayanDay]::new(1425516)).StandardNotation()) -Expected "9.17.19.13.16"
}

function Test-TzolkinDate {
    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Imix).Ordinal()) -Expected 1
    Assert -Statement ([TzolkinDate]::new(2, [TzolkinDayName]::Ik).Ordinal()) -Expected 2
    Assert -Statement ([TzolkinDate]::new(3, [TzolkinDayName]::Akbal).Ordinal()) -Expected 3
    Assert -Statement ([TzolkinDate]::new(7, [TzolkinDayName]::Chicchan).Ordinal()) -Expected 85
    Assert -Statement ([TzolkinDate]::new(13, [TzolkinDayName]::Ajaw).Ordinal()) -Expected 260

    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Imix).TrecenaDay()) -Expected 1
    Assert -Statement ([TzolkinDate]::new(3, [TzolkinDayName]::Ben).TrecenaDay()) -Expected 3
    Assert -Statement ([TzolkinDate]::new(8, [TzolkinDayName]::Kawak).TrecenaDay()) -Expected 8

    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Imix).DayName()) -Expected ([TzolkinDayName]::Imix)
    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Ben).DayName()) -Expected ([TzolkinDayName]::Ben)
    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Kawak).DayName()) -Expected ([TzolkinDayName]::Kawak)

    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Imix).StandardNotation()) -Expected "1 Imix"
    Assert -Statement ([TzolkinDate]::new(2, [TzolkinDayName]::Ik).StandardNotation()) -Expected "2 Ik'"
    Assert -Statement ([TzolkinDate]::new(3, [TzolkinDayName]::Akbal).StandardNotation()) -Expected "3 Ak'b'al"
    Assert -Statement ([TzolkinDate]::new(7, [TzolkinDayName]::Chicchan).StandardNotation()) -Expected "7 Chicchan"
    Assert -Statement ([TzolkinDate]::new(13, [TzolkinDayName]::Ajaw).StandardNotation()) -Expected "13 Ajaw"

    Assert -Statement ([TzolkinDate]::new(1, [TzolkinDayName]::Imix).AddDays(1).StandardNotation()) -Expected "2 Ik'"
    Assert -Statement ([TzolkinDate]::new(2, [TzolkinDayName]::Ik).AddDays(5).StandardNotation()) -Expected "7 Manik'"
    Assert -Statement ([TzolkinDate]::new(3, [TzolkinDayName]::Akbal).AddDays(13).StandardNotation()) -Expected "3 Kib'"
    Assert -Statement ([TzolkinDate]::new(11, [TzolkinDayName]::Akbal).AddDays(20).StandardNotation()) -Expected "5 Ak'b'al"
    Assert -Statement ([TzolkinDate]::new(11, [TzolkinDayName]::Akbal).AddDays(-1).StandardNotation()) -Expected "10 Ik'"
    Assert -Statement ([TzolkinDate]::new(11, [TzolkinDayName]::Akbal).AddDays(-260).StandardNotation()) -Expected "11 Ak'b'al"

    Assert -Statement ([TzolkinDate]::new(0).StandardNotation()) -Expected "1 Imix"
    Assert -Statement ([TzolkinDate]::new(1).StandardNotation()) -Expected "2 Ik'"
    Assert -Statement ([TzolkinDate]::new(2).StandardNotation()) -Expected "3 Ak'b'al"
    Assert -Statement ([TzolkinDate]::new(259).StandardNotation()) -Expected "13 Ajaw"
}

function Test-HaabDate {
    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Pop).Ordinal()) -Expected 1
    Assert -Statement ([HaabDate]::new(20, [HaabMonth]::Pop).Ordinal()) -Expected 20
    Assert -Statement ([HaabDate]::new(5, [HaabMonth]::Wayeb).Ordinal()) -Expected 365

    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Pop).Day()) -Expected 1
    Assert -Statement ([HaabDate]::new(2, [HaabMonth]::Pop).Day()) -Expected 2
    Assert -Statement ([HaabDate]::new(15, [HaabMonth]::Pop).Day()) -Expected 15
    Assert -Statement ([HaabDate]::new(15, [HaabMonth]::Kayab).Day()) -Expected 15
    Assert -Statement ([HaabDate]::new(17, [HaabMonth]::Muwan).Day()) -Expected 17

    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Pop).Month()) -Expected ([HaabMonth]::Pop)
    Assert -Statement ([HaabDate]::new(2, [HaabMonth]::Wo).Month()) -Expected ([HaabMonth]::Wo)
    Assert -Statement ([HaabDate]::new(3, [HaabMonth]::Wayeb).Month()) -Expected ([HaabMonth]::Wayeb)

    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Pop).StandardNotation($true)) -Expected "1 Pop"
    Assert -Statement ([HaabDate]::new(5, [HaabMonth]::Yax).StandardNotation($true)) -Expected "5 Yax"
    Assert -Statement ([HaabDate]::new(10, [HaabMonth]::Chen).StandardNotation($true)) -Expected "10 Ch'en"
    Assert -Statement ([HaabDate]::new(20, [HaabMonth]::Kankin).StandardNotation($true)) -Expected "Ending of K'ank'in"
    Assert -Statement ([HaabDate]::new(20, [HaabMonth]::Kankin).StandardNotation($false)) -Expected "Seating of Muwan"

    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Pop).AddDays(10).StandardNotation($true)) -Expected "11 Pop"
    Assert -Statement ([HaabDate]::new(13, [HaabMonth]::Pop).AddDays(10).StandardNotation($true)) -Expected "3 Wo'"
    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Wayeb).AddDays(4).StandardNotation($true)) -Expected "Ending of Wayeb"
    Assert -Statement ([HaabDate]::new(1, [HaabMonth]::Wayeb).AddDays(5).StandardNotation($true)) -Expected "1 Pop"
    Assert -Statement ([HaabDate]::new(10, [HaabMonth]::Muwan).AddDays(1000).StandardNotation($true)) -Expected "15 Yax"
    Assert -Statement ([HaabDate]::new(5, [HaabMonth]::Muwan).AddDays(-10).StandardNotation($true)) -Expected "15 K'ank'in"

    Assert -Statement ([HaabDate]::new(0).StandardNotation($true)) -Expected "1 Pop"
    Assert -Statement ([HaabDate]::new(10).StandardNotation($true)) -Expected "11 Pop"
    Assert -Statement ([HaabDate]::new(300).StandardNotation($true)) -Expected "1 Pax"
}

function Test-Plain {
    Assert -Statement (Main -Plain -LongCountDate "9.17.19.13.16") -Expected "9.17.19.13.16 5 Kib' 14 Ch'en"
    Assert -Statement (Main -Plain -LongCount -GregorianDate 0790-07-20) -Expected "9.17.19.13.16"
    Assert -Statement (Main -Plain -LongCount -GregorianDate 2022-12-30) -Expected "13.0.10.2.18"
    Assert -Statement (Main -Plain -LongCount -CalendarRound -GregorianDate 2022-12-30) -Expected "13.0.10.2.18 9 Etz'nab' 11 K'ank'in"
    Assert -Statement (Main -Plain -LongCount -CalendarRound -GregorianDate 2023-01-08) -Expected "13.0.10.3.7 5 Manik' Seating of Muwan"
    Assert -Statement (Main -Plain -LongCount -CalendarRound -GregorianDate 2023-01-08 -PreferMonthEnding) -Expected "13.0.10.3.7 5 Manik' Ending of K'ank'in"
    Assert -Statement (Main -Plain -LongCount -CalendarRound -GregorianDate 2023-04-03) -Expected "13.0.10.7.12 12 Eb' Seating of Pop"
    Assert -Statement (Main -Plain -LongCount -CalendarRound -GregorianDate 2023-04-03 -PreferMonthEnding) -Expected "13.0.10.7.12 12 Eb' Ending of Wayeb"
    Assert -Statement (Main -Plain -CalendarRound -GregorianDate 2022-12-30) -Expected "9 Etz'nab' 11 K'ank'in"
    Assert -Statement (Main -Plain -LongCount -Tzolkin -GregorianDate 2022-12-30) -Expected "13.0.10.2.18 9 Etz'nab'"
    Assert -Statement (Main -Plain -Tzolkin 2022-12-30) -Expected "9 Etz'nab'"
    Assert -Statement (Main -Plain -LongCount -Haab -GregorianDate 2022-12-30) -Expected "13.0.10.2.18 11 K'ank'in"
    Assert -Statement (Main -Plain -Haab -GregorianDate 2022-12-30) -Expected "11 K'ank'in"
    Assert -Statement (Main -Plain -LongCount -IncludeGregorianDate -LongCountDate "9.17.19.13.16") -Expected "9.17.19.13.16 (0790-07-20)"
}

function Test-Latex {
    $Nominal = 
"\newcommand{\documentversiongregoriandate}{2023--01--10\xspace}
\newcommand{\documentversionlongcount}{13.0.10.3.9\xspace}
\newcommand{\documentversiontzolkin}{7 Muluk\xspace}
\newcommand{\documentversionhaab}{2 Muwan\xspace}"

    Assert -Statement (Main -Latex -GregorianDate 2023-01-10) -Expected $Nominal
}

function Test-Json {
    $Nominal = 
"{
  `"gregorianDate`": `"2024-05-20T00:00:00`",
  `"longCountDate`": {
    `"standardNotation`": `"13.0.11.10.5`",
    `"digits`": [
      5,
      10,
      11,
      0,
      13
    ]
  },
  `"tzolkin`": {
    `"standardNotation`": `"9 Chicchan`",
    `"trecenaDay`": 9,
    `"dayName`": `"Chicchan`",
    `"dayNameOrdinal`": 4,
    `"ordinal`": 165
  },
  `"haab`": {
    `"standardNotation`": `"8 Sip`",
    `"day`": 8,
    `"monthName`": `"Sip`",
    `"month`": 2,
    `"ordinal`": 48
  }
}"

    Assert -Statement (Main -Json -LongCountDate "13.0.11.10.5") -Expected $Nominal
}

function Test-Script {
    Test-LongCountDate
    Test-TzolkinDate
    Test-HaabDate
    Test-Plain
    Test-Latex
    Test-Json
}

Test-Script

$MainParameter = @{
    GregorianDate = $GregorianDate
    LongCountDate = $LongCountDate
    CalendarRound = $CalendarRound
    LongCount = $LongCount
    Tzolkin = $Tzolkin
    Haab = $Haab
    PreferMonthEnding = $PreferMonthEnding
    IncludeGregorianDate = $IncludeGregorianDate
    Plain = $Plain
    Json = $Json
    Latex = $Latex
}

$a = [JulianDay]::FromIsoDate("-0476-05-22").Days
Write-Host "BBBBBBBBB $a"


Main @MainParameter
