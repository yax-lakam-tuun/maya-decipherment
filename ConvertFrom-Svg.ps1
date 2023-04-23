#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Converts SVG files into PDF files which can then directly used in LaTeX.

    .DESCRIPTION
    This script is used to convert SVG files into PDF files.
    LaTeX doesn't support SVG files natively.
    Some packages do exist, but the usage is a bit problematic since they usually require
    some elevated rights in the system which is not recommended due to security aspects.
    The script can either accept a list of SVG files (via parameter SvgFiles) or can grep
    for them in the current directory and below when the aforementioned parameter is ommited by
    the user.
    The DPI (Dots per inch) for the resulting PDF(s) can also be specified and defaults to 100
    when the parameter Dpi is not specified.

    .INPUTS
    None. You cannot pipe objects into this script.

    .OUTPUTS
    None. The output is undefined.

    .EXAMPLE
    Convert a list od SVG files. Note: Files have to be comma-separated.

    ./ConvertFrom-Svg.ps1 -SvgFiles a.svg, b.svg, c.svg

    .EXAMPLE
    Convert all files in current directory and below.

    ./ConvertFrom-Svg.ps1

    .EXAMPLE
    Convert a file using specified DPI.

    ./ConvertFrom-Svg.ps1 -SvgFiles a.svg -Dpi 150

    .LINK
    https://github.com/yax-lakam-tuun/maya-decipherment
#>

param (
    [int] $Dpi = 100,
    [string[]] $SvgFiles
)

if ($SvgFiles.Length -eq -0) {
    $SvgFiles = Get-ChildItem -Filter *.svg -Recurse
}

foreach ($Svg in $SvgFiles) {
    $Pdf = $Svg.ToLower().Replace('.svg', '.pdf')

    # inkscape's exit codes are not reliable so we print everything always
    # (see https://gitlab.com/inkscape/inkscape/-/issues/270)
    # the user should read the output carefully to detect possible problems
    Write-Output "Converting $Svg to $Pdf"
    inkscape --export-area-drawing --export-type=pdf --export-filename=$Pdf --export-dpi=$Dpi $Svg
}
