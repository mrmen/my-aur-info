#!/bin/bash
#
# this script allow you to know if files used
# in your pkgbuild have been modified and so the md5sum.

file=$1
pkgbuild=$2
TMPDIR=$(mktemp -d)

cd $TMPDIR

curl -s -L "${file}" > file

actual=$(md5sum file | cut -d" " -f1)
old=$(grep [0-9a-e]\{32\} $pkgbuild)

if (($actual!=$old)); then
    echo "\033[1m\033[31m out of date \033[0m"
fi

exit 0