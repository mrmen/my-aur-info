#!/bin/bash
#
# Created by MrMen <tetcheve at gmail dot com>
# First time Edited  on 02-01-2012 for v-alpha
#
# Time-stamp: <2012-02-02 13:43:56 thomas>
# 
# Version : 1-a1
#
###########################################
#
# To use this script, you will have to create
# a new directory named .my-packages in your home.
# 
# For the first use, you must specify --init.
# After that, you will be warned if theres's something new
# about you package.
#

CONFIG_FILE="$HOME/.my-packages"

function usage (){
    echo "Usage of "$0" :"
    echo "  "$0" package"
    echo "Give one argument (name of an aur package) to this script and it will let you"
    echo " know more about its infos."
    echo ""
    echo "Actually nothing work at the moment"
    echo "It's a dev version"
}


## the usefull function

function some-info (){
    package=$1
    output=$2
    temp_dir=`mktemp -d`
    cd $temp_dir
    
    wget -O  aur_page "http://aur.archlinux.org/packages.php?ID="$(package-query -As $package -f "%i") &>/dev/null
    
    cat aur_page | awk -v var=0 '{if ($0 ~ "comment-header") {print}}' | sed 's/\(.* on \)\(.*\)\( [\+-].*\)/\2/g' | wc -l >> $output
    
    if (($(package-query -As $package -f "%o"))); then
        echo "out of date" >> $output
    fi;
    
    cd ..
    rm -rf $temp_dir
    
    exit 0
}

function is_anything_new (){
    diff "$CONFIG_FILE""/""$1" "$2"
    if (($?)); then
	echo "something happened"
    fi;
}

# check args
if (($#!=1 && $#!=2)); then
    echo $#
    usage
    exit 0
fi


# check if config file exists
if [ ! -e $CONFIG_FILE ]; then
    echo $CONFIG_FILE" doesn't exist"
    exit 1
fi;
if [ ! -d $CONFIG_FILE ]; then
    echo $CONFIG_FILE" exists but is not a directory"
    exit 1
fi

# let's do it
if [ "$1" = "--init" ]; then
    if (($#==1)); then
	usage
	exit 0
    fi;
    touch "$CONFIG_FILE""/""$2"
    some-info $2 "$CONFIG_FILE""/""$2"
else
    TMP_FILE=`mktemp`
    some-info $1 $TMP_FILE
    is_anything_new $1 $TMP_FILE
    rm $TMP_FILE
fi

