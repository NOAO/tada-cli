#!/bin/bash -e
# PURPOSE: Waits until all lines in a manifest file show up in a log file.
#   (or TIMEOUT is exceeded). Manifest line may match PART of logfile line.
#
# EXAMPLE:


cmd=`basename $0`
dir=`dirname $0`

#Absolute path to this script
SCRIPT=$(readlink -f $0)
#Absolute path this script is in
SCRIPTPATH=$(dirname $SCRIPT)

VERBOSE=0
PROGRESS=0
LOGFILE=/var/log/tada/pop.log
TIMEOUT=30

usage="USAGE: $cmd [options] manifestFile
manifestFile:  Strings (one per line) that must show up in logfile for success.
               Each string can occur anywhere in any line of LOGFILE.
OPTIONS:
  -l <logfile>:: File to read for matches (default=$LOGFILE)
  -t <seconds>:: Seconds to wait for all matches to show up in logfile 
                 (default=$TIMEOUT)
  -v <verbosity>:: higher number for more output (default=0)

"


while getopts "hl:t:v:" opt; do
    #!echo "opt=<$opt>"
    case $opt in
	    h)
            echo "$usage"
            exit 1
            ;;
        v)
            VERBOSE=$OPTARG
            ;;
        l)
            LOGFILE=$OPTARG
            ;;
        t)
            TIMEOUT=$OPTARG
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
#! echo "OPTIND=$OPTIND"
for (( x=1; x<$OPTIND; x++ )); do shift; done

RAC=1 # Required Argument Count
if [ $# -lt $RAC ]; then
    echo "Not enough non-option arguments. Expect at least $RAC."
    echo >&2 "$usage"
    exit 2
fi

MANIFEST=$1


##############################################################################

function echoverbose () {
    if [ "$VERBOSE" -gt 0 ]; then
        echo $1
    fi
}
function echonverbose () {
    if [ "$VERBOSE" -gt 0 ]; then
        echo -n $1
    fi
}

function countmatches() {
    found=0
    for str in "${strings[@]%?}"; do
        if grep -F "$str" $LOGFILE > /dev/null; then
            found=$(( $found + 1 ))
        fi
    done
    echo $found
}

function mismatches() {
    for str in "${strings[@]%?}"; do
        if ! grep -F "$str" $LOGFILE > /dev/null; then
            echo "Not Found: $str"
        fi
    done
}
        
maxTries=$TIMEOUT
readarray strings < $MANIFEST
tries=0
for str in "${strings[@]%?}"; do
    echoverbose "Looking in logfile for: \"$str\""
    echoverbose "# Waiting $maxTries seconds for $str in '$LOGFILE'"
    echonverbose -n "# wait($maxTries)"
    while ! grep -F "$str" $LOGFILE > /dev/null; do
	    tries=$((tries+1))
    	    echonverbose "."
	    if [ "$tries" -gt "$maxTries" ]; then
            echoverbose ""
	        echo
	        echo "# Aborted after $maxTries seconds: \"$str\" NOT FOUND"
            total=${#strings[@]}
            found=`countmatches`
            mismatches
            echo "Found $found/$total items"
	        exit 1
	    fi
	    sleep 1
    done
    echoverbose " Done in $tries seconds"
done

exit 0

