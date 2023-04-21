#!/usr/bin/env pwsh

[CmdletBinding()]
param (
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

    if ($ExitCode -eq 0) {
        Write-Output "All checks passed."
    } else {
        Write-Output "At least one file check failed. Please see the log."
    }

    Exit $ExitCode
}

$TexFiles = Get-ChildItem -Path $RootPath -Filter *.tex -Recurse -ErrorAction SilentlyContinue -Force

Invoke-Chktex -TexFiles $TexFiles
