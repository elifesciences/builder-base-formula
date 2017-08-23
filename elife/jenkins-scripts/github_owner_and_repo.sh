#!/bin/bash
set -e
# sample output:
# elifesciences/pattern-library

# `grep -P` for recognizing the tab character
git remote -v 2>&1 \
    | grep '(fetch)' \
    | grep -P "^origin\t" \
    | sed -e 's/.*github.com[:/]\([A-Za-z0-9/-]*\)\(.git\)\{0,1\} .*/\1/g'
