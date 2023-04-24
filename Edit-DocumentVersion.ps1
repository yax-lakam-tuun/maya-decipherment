#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Updates or prints content of given document version file.

    .DESCRIPTION
    This script is used to manage the current document version.
    The document version is used to create new releases/Git tags.
    It is also used to in the LaTeX document itself (e.g. on the cover page) to inform the reader
    about the document's version.
    The version is stored in a LaTeX readable format - usally stored in document-version.tex.
    The file, however, can be specified explicitly using the parameter VersionTexPath.
    The script fulfills two purposes.
    1) Updating the document version using a given Gregorian date.
       The Gregorian date is converted to its Long Count date equivalent which is then used as
       Release version and Git tag.
       The Long Count date, the Calendar Round and the Gregorian date is then stored in the 
       specified file (see parameter VersionTexPath).

    2) Printing the long count (using parameter Long Count).
       As the Long Count is also used as Git tag, the Release workflow (see workflows/release.yml)
       needs to extract the information from the LaTeX file.

    .INPUTS
    None. You cannot pipe objects into this script.

    .OUTPUTS
    Prints information about document version file. Prints nothing in Update mode.

    .EXAMPLE
    Update document version to anno 800 AD.

    ./Edit-DocumentVersion.ps1 -Update -VersionTexPath ./document-version.tex -GregorianDate 0800-11-22

    .EXAMPLE
    Print Long Count date of document version to terminal.

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
