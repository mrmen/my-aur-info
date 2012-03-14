#!/bin/bash
#
# this script allow you to know if files used
# in your pkgbuild have been modified and so the md5sum.


# file=$1
# pkgbuild=$2
package=$1


TMPDIR=$(mktemp -d)
cd $TMPDIR


yaourt -G $package &>/dev/null
cp $package/PKGBUILD .
rm -rf $package

cat PKGBUILD | awk -v parent=0 '{if ($0 ~ "=") {parent=0} ;if (/source/) {parent=1}; if (parent==1) {print}}' | sed -e 's/\(.*=(\)\(.*\)\()\)/\2/g'> sources
touch md5sum_file

mkdir download
cd download

for file in `cat ../sources`;do
    curl -s -L "$file" |> tmp_file
    md5sum tmp_file | cut -d" " -f1  >> ../md5sum_file
done

cd ..
rm -rf download

touch actual
sed -e "/[0-9a-f]\{32\}/!d; s/\(.*'\)\([0-9a-f]\{32\}\)\('.*\)/\2/g" PKGBUILD >> actual

longueur=`wc -l actual | cut -d" " -f1`
for i in `seq 1 $longueur`; do
    old=`sed -n "$i p" actual`
    current=`sed -n "$i p" md5sum_file`
    if [ $old != $current ]; then
	echo `sed -n "$i p" sources`" is out of date"
    fi
done


cd ..
rm -r $TMPDIR

exit 0