#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Runs some tests on the given PDF document.

    .DESCRIPTION
    This script is responsible to test all LaTeX files (usually files ending with .tex).
    Currently, only the existence of the document is tested.
    The script is used in the contineous integration stage (see workflows/ci.yml) to ensure
    integrity of the generated PDF document.

    .EXAMPLE
    ./Test-Document -DocumentPath "/opt/source/somePdf.pdf"

    .INPUTS
    None. You cannot pipe objects into this script.

    .OUTPUTS
    None. The output is undefined.

    .LINK
    https://github.com/yax-lakam-tuun/maya-decipherment
#>

[CmdletBinding()]
param (
    [string]
    # The file name of the PDF document.
    [Parameter(Mandatory=$true, HelpMessage="Enter PDF document.")]
    $DocumentPath
)

function Test-Existance {
    param (
        [Parameter(Mandatory=$true)]
        [string] $DocumentPath
    )

    if (Test-Path -Path $DocumentPath -PathType Leaf) {
        Write-Output "Document $DocumentPath exists - OK"
    } else {
        Write-Error "Document $DocumentPath not found - FAILED"
        Exit 1
    }
}

Test-Existance -DocumentPath $DocumentPath

Write-Output "All tests passed."
