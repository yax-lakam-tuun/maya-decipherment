#!/usr/bin/env pwsh

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, ParameterSetName="UpdateSet")]
    [Parameter(Mandatory=$true, ParameterSetName="PrintSet")]
    [string] 
    $VersionTexPath,

    [Parameter(Mandatory=$true, ParameterSetName="UpdateSet")]
    [switch]
    $Update,

    [Parameter(Mandatory=$true, ParameterSetName="PrintSet")]
    [switch]
    $Print,

    [Parameter(Mandatory=$true, ParameterSetName="UpdateSet")]
    [ValidatePattern("\d{4}-\d{2}-\d{2}")]
    [string]
    $IsoDate
)

function Write-DocumentVersion {
    [CmdletBinding()]
    param (
        [string] $VersionTexPath
    )

    $Content = (Get-Content -Path $VersionTexPath -Raw)
    $Content -match "\\newcommand\{\\documentversionlongcount\}\{(.*)\\xspace\}" | Out-Null

    if ($Matches.Count -ne 2) {
        Write-Error "No \documentversionlongcount tag found in $VersionTexPath"
        Exit 1
    }

    Write-Output $Matches.1
}

function Update-DocumentVersion {
    [CmdletBinding()]
    param (
        [string] $VersionTexPath,
        [string] $IsoDate
    )

    ./Ask-Ajpula.ps1 -Latex -IsoDate $IsoDate | Out-File $VersionTexPath
}

if ($Print.IsPresent) {
    Write-DocumentVersion -VersionTexPath $VersionTexPath
}

if ($Update.IsPresent) {
    Update-DocumentVersion -VersionTexPath $VersionTexPath -IsoDate $IsoDate
}
