#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Updates or prints content of given document version file.

    .EXAMPLE
    Update document version to anno 800 AD.

    ./Edit-DocumentVersion.ps1 -Update -VersionTexPath ./document-version.tex -GregorianDate 0800-11-22

    .INPUTS
    None

    .OUTPUTS
    None

    .EXAMPLE
    Print Long Count date of document version to terminal

    ./Edit-DocumentVersion.ps1 -LongCount -VersionTexPath ./document-version.tex

    .LINK
    https://github.com/yax-lakam-tuun/maya-decipherment
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, ParameterSetName="UpdateSet")]
    [Parameter(Mandatory=$true, ParameterSetName="LongCountSet")]
    # Path to LaTeX file in which the version is stored/should be stored in.
    [string] 
    $VersionTexPath,

    [Parameter(Mandatory=$true, ParameterSetName="UpdateSet")]
    # Creates a new document version in LaTeX format and writes it to given Tex file.
    [switch]
    $Update,

    [Parameter(Mandatory=$true, ParameterSetName="LongCountSet")]
    # Prints Long Count portion stored in given Tex file.
    [switch]
    $LongCount,

    [Parameter(Mandatory=$true, ParameterSetName="UpdateSet")]
    [ValidatePattern("\d{4}-\d{2}-\d{2}")]
    # Gregorian date in ISO format.
    [string]
    $GregorianDate
)

function Write-LongCountDate {
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
        [string] $GregorianDate
    )

    ./Ask-Ajpula.ps1 -Latex -GregorianDate $GregorianDate | Out-File $VersionTexPath
}

if ($LongCount.IsPresent) {
    Write-LongCountDate -VersionTexPath $VersionTexPath
}

if ($Update.IsPresent) {
    Update-DocumentVersion -VersionTexPath $VersionTexPath -GregorianDate $GregorianDate
}
