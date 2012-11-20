#!/bin/bash
#
# this script allow you to know if files used
# in your pkgbuild have been modified and so the md5sum.


# file=$1
# pkgbuild=$2

if (($#!=1)); then
    exit 0
fi;


package=$1


TMPDIR=$(mktemp -d)
cd $TMPDIR




yaourt -G $package &>/dev/null
#cp $package/PKGBUILD . # old 
cp $package/* .
rm -rf $package


pkgver=$(sed -e '/pkgver=/!d; s/.*=//g' PKGBUILD)
pkgname=$(sed -e '/pkgname=/!d; s/.*=//g' PKGBUILD)

cat PKGBUILD | awk -v var=0 '{if ($0 ~ "source") {var=1}; if (var==1) {print}; if (/[\""'"'"'"]?)/) {var=0}}' | sed -e 's/.*=//g' | sed -e "s/\(.*[\"\']\)\(http.*\)\([\"\'].*\)/\2/g" > sources
sed -i 's/[()]//g' sources
# debug
#cat sources
# end debug

touch md5sum_file

mkdir download
cd download

#debug
#ls ..
#end debug

for file in `cat ../sources`;do
    fichier=$(eval echo $file)
#debug
#    echo $fichier
#end debug
    if [ -e ../$fichier ]; then
	cp ../$fichier tmp_file
# debug	
#	echo "copying"
# end debug
    else
	wget -O tmp_file $fichier &>/dev/null
    fi
    md5sum tmp_file | cut -d" " -f1  >> ../md5sum_file
done


# debug
#ls
#cat ../md5sum_file
# end debug

cd ..
rm -rf download

touch actual
sed -e "/[0-9a-f]\{32\}/!d; s/\(.*'\)\([0-9a-f]\{32\}\)\('.*\)/\2/g" PKGBUILD >> actual
#debug
#cat actual
#end debug

longueur=`wc -l actual | cut -d" " -f1`

{
is_out=0
for i in `seq 1 $longueur`; do
    old=`sed -n "$i p" actual`
    current=`sed -n "$i p" md5sum_file`
    if [ "$old" != "$current" ]; then
	is_out=1
#	eval echo `sed -n "$i p" sources`" is out of date"
    fi
done
if (($is_out)); then 
    echo -e $package" is out of date : some file are obsolet\n Try to update as soon as posible :)"
    #| mail -s "Package in AUR obsolet" tetcheve@gmail.com
fi;
}
cd ..
rm -r $TMPDIR

exit 0
