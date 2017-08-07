#!/bin/bash
set -e
# sample output:
# elifesciences/pattern-library

git remote -v 2>&1 \
    | grep '(fetch)' \
    | grep -P "^origin\t" \ # -P for recognizing the tab character
    | sed -e 's/.*github.com:\(.*\)\(.git\)\{0,1\} .*/\1/g'
