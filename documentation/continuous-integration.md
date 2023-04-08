# Trunk-based development and Continuous Integration
The whole idea of trunk-based development is, that there is basically one branch, 
often called `main`, on which the latest version resides on.
For a detailed introduction on trunk-based development please refer to 
https://trunkbaseddevelopment.com/.

There are two important aspects to this project:
* Every release is created from `main` branch.
* All changes which should become part of the next version are pushed to short-lived 
  feature branches before they can be merged onto `main`.
  
## Release from trunk
Every release is created from `main` branch.
This means, there won't be any release branches.
There are no changes necessary just for this release.
Every change happens on `main` as the document and its sources are to be considered
a 'snapshot' taken at a certain point in time.
The release version is the long count representation of the document's date 
(see [Releases](releases.md)).

## Short-lived feature branch
One or more persons work on a branch branched from `main` over a small periods of time, flowing through pull requests including code-review and build automation before "integrating" 
aka merging into `main`.
The `main` branch is protected, so the only way for code to get merged, is via pull requests.

The pull requests include a review process.
The idea is, that the changes should be checked (ideally independently of the original writer) 
to make sure there the text is correct and matches to the rest of the document.
The build automation checks if a PDF document can be generated and whether
problems arose during the process (e.g. LaTeX issues, spelling problems and so on).
If there are problems, the branch is blocked from being merged until all issues have been resolved.
That is the so-called `continuous integration` workflow.

After the PR has been reviewed and built successfully, it is ready to be merged.
The PR can then be manually merged, afterwards all changes made their way onto `main`.

## GitHub workflows
TODO