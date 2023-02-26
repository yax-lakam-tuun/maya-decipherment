# Purpose of this project
The Maya hieroglyphs and the Maya script have been a mystery for centuries.
Scholars from all over world tried to crack the `Mayan Code' since the early 1830s.
But it took many decades until scholars made significant progress in the decipherment until to
this very day.
This project has the goal to collect all the breakthroughs in the decipherment of Maya hieroglyphs
and illustrate them with examples from all available hieroglyphic sources 
(e.g. from the great stela and stone inscriptions).

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
And maybe it makes more sense in some parts to jump back and forth in time for educational purposes.
But the general guideline (aka rule of thumb) should be, to start from the early stages of 
decipherment until to today.

# Current document
TODO

# How to build
You need a LaTeX distribution installed and available in your terminal.
The shell script `compile.sh` will compile the document.
The location of the build files etc. can be configured via command line arguments.
Alternatively, one can use a docker container to compile.

# Why is it open source?
[Open source](documentation/open-source.md)

# Why LaTeX?
[Latex](documentation/latex.md)

# What is GIT?
To keep track of all changes being applied to the project, it is useful to have a standard tool which allows to store and manage the folder structure of the project.
One way to approach this, is to use an Source Code Management(SCM).
It is a tool which allows to maintain the project and keeps track of all the changes being applied to it.
If you want to know, you can, for instance, look at the introduction of Atlassian: https://www.atlassian.com/git/tutorials/source-code-management

# Trunk-based development and Continuous Integration
[CI](documentation/continuous-integration.md)

# VSCode and docker
[VSCode](documentation/vscode.md)

# Releases
[Version scheme, changelog and releases](documentation/releases.md)
