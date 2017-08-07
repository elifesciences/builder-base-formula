#!/bin/bash
set -e

git remote -v 2>&1 | grep '(fetch)' | grep "^origin " | sed -e 's/.*github.com:\(.*\)\(.git\)\{0,1\} .*/\1/g'
