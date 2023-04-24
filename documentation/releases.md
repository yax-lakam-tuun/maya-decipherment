# Releases
All releases can be found [here](../releases).
Every release contains the source code the document is based on, a changelog with a description 
of the all changes which have been made and the final document as PDF.
The document itself will never really be completed as the decipherment is an ongoing 
process with no foreseeable ending.
Therefore, there will be a continuous stream of releases once in a while.
This also means that a release is always a snapshot of what has been condensed from the past 
and the state the decipherment process is currently in.

# Version scheme
The version of the document is usually the date of the release. 
The release date is converted to a Maya Long Count date using the Martin-Skidmore 
correlation (584286) and then written out in the standard Long Count notation.
For example, `2022-12-30` would be written as `13.0.10.2.18`.

# Changelog
The changelog format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to a variant of [Calendar Versioning](https://calver.org/).
It can be found [here](../CHANGELOG.md).
Every changelog entry consists of the long count date and its Gregorian equivalent 
(using ISO format YYYY-MM-DD). Here's an example: 

    ## 13.0.10.7.3 - 2023-03-25
    
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