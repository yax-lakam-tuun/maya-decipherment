# Changelog
[Version scheme, changelog and releases](documentation/releases.md)
The changelog format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to a variant of [Calendar Versioning](https://calver.org/).

Version scheme:

The version of the document is basically the date of the release. 
The release date is converted to a Maya Long Count date using the Martin-Skidmore 
correlation (584286) and then written out in the standard Long Count notation.
For example, `2022-12-30` would be written as `13.0.10.2.18`.

Every changelog entry consists of the version string and the Gregorian release date 
using ISO format YYYY-MM-DD. Here's an example: 

    ## [<long count of release date>] - <release date in ISO format>
    
    ### Added
    - New reading of some hieroglyph
    - Some insights on Palenque inscriptions

    ### Changed
    - Refactored long count chapter
    - Improved some lintel drawings of Yaxchilan

    ### Removed
    - Cleaned up some unsure readings of TXYZ
    - Some unused images from chapter XYZ

    ### Fixed
    - Fixed some wrong spellings
    - Updated some old transcriptions regarding Dresden codex p.XY