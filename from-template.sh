#!/bin/bash

echo "$1"

git clone "git@github.com:racket-templates/$1.git" $2

cd "$2"

rm -rf .git
