#!/bin/bash

git clone "$1$2.git" $3
if [ -d "$3" ]; then
	cd "$3"
	rm -rf .git
else
	echo "Cloning $1$2 failed"
fi
