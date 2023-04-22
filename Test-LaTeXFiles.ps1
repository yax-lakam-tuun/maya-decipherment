#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Runs tests on each LaTeX file ending with.tex and outputs the result.

    .DESCRIPTION
    This script is responsible to check all LaTeX files (usually files ending with .tex).
    Currently, only one check is performed.
    The utility tool 'chktex' reports typographic and other errors in LaTeX.
    The script is used in the contineous integration stage (see workflows/ci.yml) to ensure
    integrity of all LaTeX files.

    .EXAMPLE
    Search in current directory and below.

    ./Test-LaTexFiles.ps1

    .INPUTS
    None. You cannot pipe objects into this script.

    .OUTPUTS
    None. The Output is undefined.

    .EXAMPLE
    Search in specific folder and below.

    ./Test-LaTexFiles.ps1 -RootPath /opt/source

    .LINK
    https://github.com/yax-lakam-tuun/maya-decipherment

#>

[CmdletBinding()]
param (
    # The starting path to look for Tex files.
    [string] $RootPath = "."
)

function Invoke-Chktex {
    param (
        [string[]] $TexFiles
    )

    $ChktexrcPath = "$PSScriptRoot/.chktexrc"
    $ExitCode = 0
    Write-Progress -Activity "Testing Tex files" -PercentComplete 0
    $Percent = 100 / $TexFiles.Length
    $PercentCompleted = 0
    foreach ($File in $TexFiles) {
        $ShortPath = Resolve-Path -Relative $File
        $Output = & chktex -q -l "$ChktexrcPath" "$File" 2>&1 | Out-String
        if ($?) {
            Write-Progress -Activity "OK" -PercentComplete $PercentCompleted
        } else {
            Write-Error "Testing $ShortPath FAILED"
            Write-Error $Output
            $ExitCode = 1
        }
        $PercentCompleted += $Percent
    }

    if ($ExitCode -ne 0) {
        Write-Error "At least one file check failed. Please see the log."
        Exit $ExitCode
    }
}

$TexFiles = Get-ChildItem -Path $RootPath -Filter *.tex -Recurse -ErrorAction SilentlyContinue -Force

Invoke-Chktex -TexFiles $TexFiles

Write-Output "All checks passed."
