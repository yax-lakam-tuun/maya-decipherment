# Purpose of this project
The Maya hieroglyphs and the Maya script have been a mystery for centuries.
Scholars from all over world tried to crack the `Mayan Code' since the early 1830s.
But it took many decades until scholars made significant progress in the decipherment until to
this very day.
This project has the goal to collect all the breakthroughs in the decipherment of Maya hieroglyphs
and illustrate them with examples from all available hieroglyphic sources like the great stela and 
stone inscriptions, the handwritings on pottery or the Maya books etc.

# Basic idea
The basic idea is to write a document which covers as much as possible from the history of 
decipherment of the Maya hieroglyphs.
Every piece of decipherment is backed up and cited with the corresponding scientific paper, book
or article.
The document derived from all the insights from all the scholars from all over the world over
so many decades shall be a good starting point for basically everyone interested in reading
the hieroglyphs and to understand the long process it took to read the writings of the old 
Maya (again).
The document should be roughly written in a chronological way.
Since the decipherment process is not a linear process, this won't be possible for everything 
though. 
Sometimes it will make more sense in some parts to jump back and forth in time for 
educational purposes.
But the general guideline (aka rule of thumb) should be, to start from the early stages of 
decipherment until to today.

# Releases
All releases of the document can be found here: 
https://github.com/yax-lakam-tuun/maya-decipherment/releases
Every release contains the source code the document is based on, a changelog with a description 
of the all changes which have been made and final document as PDF.
Please see [version scheme, changelog and releases](documentation/releases.md) 
for more information.

# How to build
You need a LaTeX distribution installed and available in your terminal.
The shell script `compile.sh` will compile the document.
The location of the build files etc. can be configured via command line arguments.
Alternatively, one can use a docker container to compile.

# Open source
This document is open source which means everybody can work with it, improve it and give feedback.
Please see [Open source](documentation/open-source.md) chapter for more information.

# LaTeX
LaTeX is a mark-up language which allows creating big scalable documents by writing
plain-old text using commands to enrich the text, embed images and tables, cite and reference
other sources like papers, books and websites scientifically.
This project used LaTeX to compile the final document.
Please see [Latex](documentation/latex.md) chapter for more information.

# Source cntrol management
To keep track of all changes being applied to the project, it is useful to have a standard tool 
which allows to store and manage the folder structure of the project.
One way to approach this, is to use an Source Code Management(SCM).
It is a tool which allows to maintain the project and keeps track of all the changes 
being applied to it.
If you want to know, you can, for instance, look at the introduction of Atlassian: 
https://www.atlassian.com/git/tutorials/source-code-management

# Trunk-based development and continuous integration
This project uses a trunk-based development approach.
All changes have to be pushed to the `main` branch in order to be compiled in to the final document.
The process which controls and manages is called `Continuous Integration`.
Please see [CI](documentation/continuous-integration.md) chapter for more information.

# VSCode
VSCode is an Integrated Development Editor(IDE).
It can be used to edit this project.
Please see the [VSCode](documentation/vscode.md) chapter for more information.

# Docker
This project utilizes Docker to virtualize the LaTeX environment used during the development 
process when VSCode is used in a devcontainer and in the continuous integration workflow.
Please see the [Docker] chapter for more information about this technology and how it is used.
