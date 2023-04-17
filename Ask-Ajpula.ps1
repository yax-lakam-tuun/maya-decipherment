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
        return [Math]::Floor($this.Index / $this::WinalDayCount) -as [HaabMonth]
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

    Write-Warning "Test failed."
    Write-Warning "Actual:   $Actual"
    Write-Warning "Expected: $Expected"
    Write-Error "Test failed"
    Exit 1
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

function Test-Script {
    Test-TzolkinDate
    Test-HaabDate
}

Test-Script

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

