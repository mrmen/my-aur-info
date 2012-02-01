#!/bin/bash
#
# Created by MrMen <tetcheve at gmail dot com>
#   on 02-01-2012
# 
# Time-stamp: <2012-02-01 23:22:02 thomas>
#
#


function usage (){
    echo "Usage of "$0" :"
    echo "  "$0" package"
    echo "Give one argument (name of an aur package) to this script and it will let you"
    echo " know more about its infos."
    echo ""
    echo "Actually nothing work at the moment"
    echo "It's a dev version"
}


# here jasspa-me will be replaced by the argumens

wget -O /tmp/test "http://aur.archlinux.org/packages.php?ID="$(package-query -As jasspa-me -f "%i") &>/dev/null

cat /tmp/test | awk -v var=0 '{if ($0 ~ "comment-header") {print}}' | sed 's/\(.* on \)\(.*\)\( [\+-].*\)/\2/g'

if (($(package-query -As jasspa-me -f "%o"))); then
    echo "jasspa-me is out of date"
else
    echo "jasspa-me is up to date"
fi

exit 0