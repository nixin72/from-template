#!/bin/bash

echo "$1"

pwd

git clone "git@github.com:racket-templates/$1.git" $2

cd "$2"

rm -rf .git
