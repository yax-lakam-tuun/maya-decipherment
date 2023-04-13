#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Compiles TeX project into PDF document.
#>

param (
    [string]

    [Parameter(HelpMessage="Enter LaTeX file to compile.")]
    # The TeX file to be compiled.
    $TexFile = "main.tex",

    [string]
    # The path to the TeX source files. Usually the root of a TeX project.
    [Parameter(HelpMessage="Enter path in which LaTeX sources are located.")]
    $SourcePath="$PSScriptRoot",

    [string]
    # The path to the output directory. The final document will be placed there, too.
    [Parameter(HelpMessage="Enter path in which output files can be stored.")]
    $BuildPath="$SourcePath/build",

    [string]
    [Parameter(HelpMessage="Enter name of the final PDF document.")]
    # The file name of the PDF document.
    $DocumentName="$((Get-Item $TexFile).BaseName)"
)

function Write-Summary {
    Write-Output "Compiling to $BuildPath/$DocumentName.pdf"
    Write-Output ""
    Write-Output "Settings:"
    Write-Output "  Name of document: $DocumentName"
    Write-Output "  Source path:      $SourcePath"
    Write-Output "  Build path:       $BuildPath"
    Write-Output "  Tex file:         $TexFile"
    Write-Output ""
    Write-Output "Invoking latexmk..."
    Write-Output ""
}

function Invoke-LaTeX {
    Set-Location "$SourcePath"
    latexmk `
        -cd `
        -synctex=1 `
        -interaction=nonstopmode `
        -file-line-error `
        -pdf `
        -Werror `
        -jobname="$DocumentName" `
        -outdir="$BuildPath" `
        "$TexFile"
}

Write-Summary
Invoke-LaTeX
