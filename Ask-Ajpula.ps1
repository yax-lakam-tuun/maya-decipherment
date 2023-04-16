
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
        
        while($Days -Ne 0) {
            $LowerPart = Get-Remainder -Number $Days -Divisor $NextWeight
            $Result += $LowerPart / $CurrentWeight

            $Days = $Days - $LowerPart
            $CurrentWeight = $NextWeight
            $NextWeight = ($NextWeight -Eq 20) ? 360 : 20 * $NextWeight
        }
        $this.Digits = $Result
    }

    [string] StandardNotation() {
        $StringDigits = $this.Digits -As [string[]]
        [array]::Reverse($StringDigits)
        return $StringDigits -Join "."
    }

    [MayaNumber] MayaNumber() {
        $Weight = 1
        $Sum = 0
        foreach($Digit in $this.Digits) {
            $Sum += $Digit * $Weight
            $Weight = ($Weight -Eq 20) ? 360 : 20 * $Weight
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
    [ValidateRange(1,13)][int] $TrecendaDay = 1
    [TzolkinDayName] $DayName = [TzolkinDayName]::Imix

    TzolkinDate( [int] $TrecendaDay, [TzolkinDayName] $DayName) {
        $this.TrecendaDay = $TrecendaDay
        $this.DayName = $DayName
    }

    static [int] $DayCount = 260
    static [int] $DayNameCount = 20
    static [int] $TrecenaDayCount = 13
    static [int] $TrecenaDayMin = 1
    static [int] $TrecenaDayMax = 13

    [string] StandardNotation() {
        $TrecendaDayString = $this.TrecendaDay -As [string]
        $DayNameString = Get-TzolkinDayStandardName -DayName $this.DayName
        return $TrecendaDayString + " " + $DayNameString
    }

    [int] OrdinalDay() {
        $TrecenaDay0 = $this.TrecenaDay - [TzolkinDate]::TrecenaDayMin
        $DayName0  = $this.DayName -As [int]
        $X = $DayName0 * (-3) * [TzolkinDate]::TrecenaDayCount + 
             $TrecenaDay0 * 2 * [TzolkinDate]::DayNameCount
        $Ordinal0 = $(Get-Remainder -Number $X -Divisor $([TzolkinDate]::DayCount))
        return 1 + $Ordinal0
    }

    [TzolkinDate] AddDays([int] $Days) {
        $TrecenaDay0 = $this.TrecendaDay - [TzolkinDate]::TrecenaDayMin
        $DayName0  = $this.DayName -As [int]
        $NewTrecenaDay0 = Get-Remainder -Number ($TrecenaDay0 + $Days) -Divisor $([TzolkinDate]::TrecenaDayCount)
        $NewTrecenaDay = [TzolkinDate]::TrecenaDayMin + $NewTrecenaDay0
        $NewDayName = Get-Remainder -Number ($DayName0 + $Days) -Divisor $([TzolkinDate]::DayNameCount)
        return [TzolkinDate]::new($NewTrecenaDay, $NewDayName)
    }
}

            $(Get-Remainder -Number (1 + ($this.TrecendaDay - 1 + $Days)) -Divisor 13),
            $(Get-Remainder -Number ($this.DayName + $Days) -Divisor 20)
        )
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
$t = [TzolkinDate]::new(1, [TzolkinDayName]::Ajaw).AddDays(19)
#$t = [TzolkinDate]::new(1, [TzolkinDayName]::Imix)
Write-Output $t
Write-Output $t.OrdinalDay()
Write-Output $t.StandardNotation()


#poco_uinic_eclipse_long_count = [16, 13, 19, 17, 9]
#poco_uinic_eclipse_date = datetime.datetime(790, 7, 20) # julian date 16 July 790
#poco_uinic_eclipse_maya_number = MayaNumber.from_long_count_digits(poco_uinic_eclipse_long_count)
