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
[here](https://trunkbaseddevelopment.com/).# Trunk-based development and Continuous Integration
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