#!/bin/bash -e
# PURPOSE: Waits until all lines in a manifest file show up in a log file.
#   (or TIMEOUT is exceeded)
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

usage="USAGE: $cmd [options] match [match ...]
OPTIONS:
  -l <logfile>:: File to read for matches (default=$LOGFILE)
  -p <progress>:: Number of progress updates per second (default=0)
  -t <seconds>:: Seconds to wait for match to show up in logfile (default=$TIMEOUT)
  -v <verbosity>:: higher number for more output (default=0)

"


while getopts "hl:p:t:v:" opt; do
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
        p)
            PROGRESS=$OPTARG # how often to report progress
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



maxTries=$TIMEOUT
readarray strings < $MANIFEST
for str in "${strings[@]}"
do           
    if [ "$VERBOSE" -gt 0 ]; then
       echo "Looking in logfile for: \"$str\""
       echo "# Waiting $maxTries seconds for $str in '$LOGFILE'"
    fi
    tries=0
    echo -n "# wait"
    while ! grep -F "\'$str\'" $LOGFILE > /dev/null; do
	    tries=$((tries+1))
	    echo -n "."
	    if [ "$tries" -gt "$maxTries" ]; then
	        echo
	        echo "Aborted after maxTries=$maxTries: $str NOT FOUND"
	        exit 1
	    fi
	    sleep 1
    done
    echo " Done in $tries seconds"
done

exit 0

