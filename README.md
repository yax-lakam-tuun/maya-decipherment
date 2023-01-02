# Purpose of this project
The Maya hieroglyphs and the Maya script have been a mystery for centuries.
Scholars from all over world tried to crack the `Mayan Code' since the early 1830s.
But it took many decades until scholars made significant progress in the decipherment until to
this very day.
This project has the goal to collect all the breakthroughs in the decipherment of Maya hieroglyphs
and illustrate them with examples of inscriptions and other write-ups.

# Basic idea
The basic idea is to write a document which covers as much as possible from the history of 
decipherment of the Maya hieroglyphs.
Every piece of decipherment is backed up and cited with the corresponding scientific paper, book
or article.
The document derived from all the insights from all the scholars from all over the world over
so many decades shall be a good starting point for basically everyone interested in reading
the hieroglyphs to understand the long process it took to read the writings of the old Maya (again).
The document should be roughly written in a chronological way.
Since the decipherment process is not a linear process, this won't be possible for everything.
But the general guideline (aka rule of thumb) should be, to start from the early stages of 
decipherment until to today.

# Why is it open source?
The project is open source and free.
Knowledge should be free and accessible to everyone.
The history of deciperment of Maya hieroglyphs should be readable and understandable to anyone
interested in this manner.
All texts, images and illustrations should be publicly available, so that the great
process of decipherment can be shared with everyone around the world. 

# Who can contribute?
Any help is greatly appreciated.
If you find problems within the document of any kind, please feel free create issues
which address your findings.
This will greatly help to improve the project.

## How can I contribute?
If you would like to become part of the project, you are more than welcome to do so.
Please get in touch.
The one important thing is, that you have an account on GitHub.
Then, it's easy to become a collaborator and join the project.

## Authoring
If you would like to become a writer for the project, then this part is for you.
Once you are a collaborator, you can create a branch and work on the document as much as you like.
Whether it is small change or maybe some major refactoring is totally up to you.
However, in order to get applied to the document, a review by at least one or two reviewers is necessary.
So, when you are done with your changes, one has to open a pull request for the `main` branch.
After the reviewers give their okay and the continuous integration is green, your contribution will be
part of the project.

# Why LaTeX?
LaTeX is a mark-up language which allows creating big scalable documents by writing
plain-old text using commands to enrich the text, embed images and tables, cite and reference
other sources like papers, books and websites scientifically.
The project is then compiled by so-called Tex distribution (e.g. Tex Live) to produce the final
document, usually a PDF file.
One writes in the mark-up language in a text editor of choice and generates the document afterwards.
In this way it's not a WYSIWYG-style of writing like for example in Word.
The document regardless whether it is a book, article etc. can be split in different files
including subfolders.
Therefore, it is possible to create structure of folders and files to separate several concerns
like chapters, paragraphs or appendixes.
It has several packages which deals with many aspects of writing (e.g. graphics, math symbols).
It's even possible to define your own commands which enables one to program and automate
extensive tasks and simplifies the way one writes text.
See the [project site of LaTeX](https://www.latex-project.org//) for more information.

# Trunk-based development and Continuous Integration
The whole idea of trunk-based development is, that there is basically one branch the whole work
resides on.
Every version (aka release) is based on this branch.
Historically, this branch has been called `trunk` (therefore the name).
Nowadays, it is usually called `main`.
So, all releases are done from `main`.
(Unfinished) work which should come into the next release, resides on branches from `main`.
After the work has been reviewed and checked on so-called pull requests, the work eventually makes
its way to `main`.
The `main` branch is protected, so the only way for code to get merged, is via pull requests.
The pull requests include a review process.
The idea is, that work should be checked independently of the original writer to make sure there
the text is correct and matches to the rest of the document.
Additionally, the pull request checks if a PDF document can be generated and whether
LaTeX problems arose during the process.
If there are problems, the branch is blocked from being merged until all issues have been resolved.
That is the so-called `continuous integration` workflow.
If everything is fine, the pull request can be merged.
For more information on trunk-based development and the git branch model can be found 
[here](https://trunkbaseddevelopment.com/).

# How to build
You need a LaTeX distribution installed and available in your terminal.
The shell script `compile.sh` will compile the document.
The location of the build files etc. can be configured via command line arguments.
Alternatively, one can use a docker container to compile.

## VSCode and docker
[VSCode](https://code.visualstudio.com/) is a source code editor and development tool.
It has the opportunity to be used in conjunction with docker containers 
(see [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)).
This project fully supports docker containers as it is also used during 
the continuous integration cycle.
It's an easy and isolated way to create a LaTeX environment and everything a consumer or writer
needs to compile the final PDF file.

# Changelog
The changelog format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to a variant of [Calendar Versioning](https://calver.org/).

Version scheme:

The version of the document is basically the date of the release. 
The release date is converted to a Maya Long Count date using the Martin-Skidmore 
correlation (584286) and then written out in the standard Long Count notation.
For example, `2022-12-30` would be written as `13.0.10.2.18`.

Every changelog entry consists of the version string and the Gregorian release date 
using ISO format YYYY-MM-DD: 

`[<long count of release date>] - <release date in ISO format>`
