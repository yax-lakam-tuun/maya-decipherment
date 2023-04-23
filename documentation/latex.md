# LaTeX
LaTeX is a mark-up language which allows creating big scalable documents by writing
plain text using commands to enrich the text, embed images and tables, cite and reference
other sources like papers, books and websites scientifically.
The project is then compiled by so-called Tex distribution (e.g. Tex Live) to produce the final
document, usually a PDF file.
One writes in the mark-up language in a text editor of choice and generates the document afterwards.
Writing a text this way is not a WYSIWYG-style of writing like for example in Word where you see 
how the document looks like.
With LaTeX one writes plain text and formatting commands to tell LaTeX how the document 
should look like.
The compilation process will generate the final and well-formatted document.
The advantage of this approach is, that the style and appearance can be easily changed by set 
of instructions which affects the document immediately and (maybe) globally.

The document regardless whether it is a book or article can be split in different files
including sub folders.
Therefore, it is possible to create structure of folders and files to separate several concerns
like chapters, paragraphs or appendixes.
It has several packages which deals with many aspects of writing (e.g. graphics, math symbols).
It's even possible to define your own commands which enables one to program and automate
extensive tasks and simplifies the way one writes text.
See the [project site of LaTeX](https://www.latex-project.org//) for more information.

# Installation
There are many guides out there which explain in detail how to install LaTeX on your system.
LaTeX is usually shipped in so-called distributions.
MikTex is one of them and is available for Windows, Linux and macOS.
Fully integrated editors with syntax highlighting and auto completion are also available.
(for example TeXstudio or TEXMAKER).
Integrated Development Editors(IDE) like [VSCode](vscode.md) can be used in conjunction with LaTeX extensions.
Despite the claims above that LaTeX is written in plain text, there are indeed WYSIWYG editors
available (for example LyX).

## Docker
LaTeX can also be used in virtualized environments like Docker containers.
On how to use Docker containers with LaTeX, 
please see chapter [Docker](../container/README.md) and [VSCode](vscode.md).

# Folder structure
All LateX code is written in files ending with `.tex`.
Some code also resides in `.sty` files, but that's just a small portion of LaTeX projects.
In less complex projects, it can be sufficient to have all the text in one single tex file.
But for bigger projects, it makes sense to split the content to more files.
This is useful to keep the context as clean as possible.
It also makes editing much easier.
Therefore, this project is also split in many different files.

## Chapters
Every chapter resides in a separate sub folder.
The chapter's tex file is named after the chapter's title 
(e.g. introduction.tex for the introduction chapter).
The advantage is that with this approach every chapter can be compiled separately. 
This greatly reduces compilation times and it might be useful to ``publish'' 
single chapters if necessary.
Then, the main document [main.tex](../main.tex) combines all chapters by 
including the according subfolders.
If necessary, a chapter can also be split into two or more sub folders.

## Graphics
Images are put into a separate sub folder named 'img' next to the tex file.
To ensure proper scaling, drawings like hieroglyphs etc. shall be stored as 
`Scalable Vector Graphics` (SVG).
SVGs are not natively supported by LaTeX.
Therefore, they have to be converted.
The script [ConvertFrom-Svg.ps1](../ConvertFrom-Svg.ps1) can be used to make the conversion.
Usage: `ConvertFrom-Svg.ps1 -SvgFiles <path/to/file.svg>`. 
This will produce a PDF named `path/to/file.pdf`.
Other images like photos and such should be stored as JPG.
Formats like PNGs are discouraged since there pictures take a lot of space and 
have to be converted by LaTeX during the compile process which might be very time consuming.

## References
This project uses BibLaTeX to organize and display all used sourced and references.
Even though the chapters are split into several files, all referenced are maintained in 
the single file [references.bib](../references.bib).

# Tex file structure
The tex files should have a maximum of 100 characters per line.
Exceptions are allowed if and only if the reading of the code would suffer from wrapping the 
lines (e.g. when using tables with many columns which exceed the limit).
Every sentences starts with  new line.
This makes it easier to read the document line by line.
The real line wrapping etc. is done by LaTeX anyways.
As always, readability should be the most important criterion when writing the text.

# Example structure
Simple tree structure featuring two chapters namely Introduction and reading order with image files:
* introduction
   * introduction.tex
   * img
      * maya-vase.svg
      * noble-shell.svg
* reading-order
   * reading-order.tex
   * img
      * palenque-tablet.svg

# Files
There are some files like scripts which have a special function inside the project.
Here's a short summary:
* [document-version.tex](../document-version.tex): 
  The current version of the document as it is used for a possible release.
  Managed by [Edit-DocumentVersion.ps1](Edit-DocumentVersion.ps1).
* [preamble.sty](../preamble.sty): Entry point for everything LaTeX in this project. 
  Includes used LaTeX libraries and defines some settings used in the document.
* [maya.sty](../maya.sty): Library for maya specific LateX command (e.g. hieroglyph commands etc.)
* [references.bib](../references.bib): All references used by BibLaTeX.