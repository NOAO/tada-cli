#!/bin/bash -e
# PURPOSE: Install instrument personalities to local FITS dir.
#   Intended for use before rsync to dropbox.
#
# EXAMPLE:
#
# AUTHORS: S.Pothier

cmd=`basename $0`
dir=`dirname $0`

SCRIPT=$(readlink -f $0)      #Absolute path to this script
SCRIPTPATH=$(dirname $SCRIPT) #Absolute path this script is in

VERBOSE=0
PERS=0

usage="USAGE: $cmd [options] destdirs
OPTIONS:
  -p <yaml>:: Personality to install for instrument (default=NONE)
  -v <verbosity>:: higher number for more output (default=0)

destdir:: Typically, <fitsdir>/*/<instrument>  or <fitsdir>/*/*
"

while getopts "hp:v:" opt; do
    echo "opt=<$opt>"
    case $opt in
	h)
            echo "$usage"
            exit 1
            ;;
        v)
            VERBOSE=$OPTARG
            ;;
        p)
            PERS="$PERS $OPTARG" 
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;

    esac
done
#echo "OPTIND=$OPTIND"
for (( x=1; x<$OPTIND; x++ )); do shift; done


RAC=1 # Required Argument Count
if [ $# -lt $RAC ]; then
    echo "Not enough non-option arguments. Expect at least $RAC."
    echo >&2 "$usage"
    exit 2
fi


#!echo "PERS=$PERS"
#!echo "VERBOSE=$VERBOSE"
#!echo "Remaining arguments:"
#!for arg do echo '--> '"\`$arg'" ; done


##############################################################################



for PER in $PERS; do
    yaml="$personalities/ops/$PERS.yaml"
    if [ -f $yaml ]; then
        for pdir; do
            cp -v $yaml $pdir
        done        
    fi
done
