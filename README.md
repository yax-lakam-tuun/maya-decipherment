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
All releases of the document can be found 
[here](https://github.com/yax-lakam-tuun/maya-decipherment/releases).
Every release contains the source code the document is based on, a changelog with a description 
of the all changes which have been made and the final document as PDF.
Please see the chapter about [releases](documentation/releases.md) for more information.

# LaTeX
This project is based LaTeX - a mark-up language which allows creating big scalable documents 
by writing plain-old text using commands to enrich texts, embed images and tables, cite and 
reference other sources like papers, books and websites scientifically and so on.
That means, a LaTeX environment must be available on your system in order to generally compile 
a PDF document from any given LateX source.
If you have a LaTeX distribution (e.g. TeXLive) available in your terminal, you can execute
the provided script [compile.sh](compile.sh) which will generate the document.
For more information on how to setup and use LaTeX, 
please have a look at chapter [LaTeX](documentation/latex.md).

# Open source
This document is open source which means everybody can work with it, improve it and give feedback.
The history of deciperment of Maya hieroglyphs should be readable and understandable to anyone
interested in this manner.
All texts, images and illustrations are be publicly available, so that the great
process of decipherment can be shared with everyone around the world. 
The project uses the [MIT license](LICENSE) which basically allows everyone to use the code, 
the texts etc. the they want as long as they credit the project.


# How can I send feedback?
If you find problems within the document of any kind or with the infrastructure of this project, 
please feel free to create issues which address your findings.
This will greatly help to improve the project.
Any help is greatly appreciated.
You can either create an issue on github directly.
This requires a GitHub account.
You can also get in touch with via academia.edu 
[here](https://independent.academia.edu/SebastianBauer16).

# Source control management
To keep track of all changes being applied to the project, it is useful to have a standard tool 
which allows to store and manage the folder structure and development of the project.
One way to approach this, is to use an Source Code Management(SCM).
It is a tool which allows to maintain the project and keeps track of all the changes 
being applied to it.
[Github](github.com) uses GIT for that purpose.
If you want to know more, you can look at some introduction of Atlassian: 
* https://www.atlassian.com/git/tutorials/source-code-management
* https://www.atlassian.com/git/tutorials/what-is-git

# Trunk-based development and continuous integration
This project also uses a trunk-based development approach.
All changes have to be pushed to the `main` branch in order to be compiled in to the final document.
The process which controls and manages that is called `Continuous Integration`.
Please see [CI](documentation/continuous-integration.md) chapter for more information.

# IDE
VSCode is an Integrated Development Editor(IDE).
It is one way to work with this this project.
However, there are many alternatives out there.
Even a basic text editor is enough.
If you would like to know more about VSCode, 
please see the [VSCode](documentation/vscode.md) chapter for more information.

# Docker
This project utilizes Docker to virtualize the LaTeX environment.
It is used by the infrastructure of the continuous integration process.
It can also be used as a so-called devcontainer when being combined with VSCode.
Please see the [Docker] chapter for more information about this technology and how it is used.
