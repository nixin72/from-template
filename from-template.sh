#!/bin/bash

echo "$1"
pwd

git clone "https://github.com/racket-templates/$1.git" $2
if [ -d "$2" ]; then
	cd "$2"
	rm -rf .git
else
	echo "Cloning $1 failed"
fi
