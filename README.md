

# Purpose of this project
The Maya hieroglyphs and the Maya script have been a mystery for centuries.
Scholars from all over world tried to crack the `Mayan Code' since the early 1830s.
But it took almost 150 years until scholars made significant progress in the decipherment until to
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


# Who can contribute?

# How can I contribute?

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

# Who owns the project?

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
