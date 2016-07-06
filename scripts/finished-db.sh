#!/bin/bash -e
# PURPOSE: Waits until all source files in sqlite DB get archived.
#   (or TIMEOUT is exceeded). 
#
# Derived from finished-log.sh
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
AUDITDB="/var/log/tada/audit.db"
TIMEOUT=10

usage="USAGE: $cmd [options] srcpath ...
srcpath:: Absolute path names.  Will wait for all to have SUCCESS non-null

OPTIONS:
  -t <seconds>:: Seconds to wait for all matches to show up in logfile 
                 (default=$TIMEOUT)
  -v <verbosity>:: higher number for more output (default=0)
  -a <auditdb>:: sqlite3 DB containing audit records  (default=$AUDITDB)

"


while getopts "ha:t:v:" opt; do
    #!echo "opt=<$opt>"
    case $opt in
	h)
            echo "$usage"
            exit 1
            ;;
        v)
            VERBOSE=$OPTARG
            ;;
        a)
            AUDITDB=$OPTARG
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

SRCFILES="$*"


##############################################################################

function num_pending () {
    cnt=`echo "SELECT count(*) FROM audit WHERE success IS NULL;" | sqlite3 $AUDITDB`
    echo $cnt
}
    
function mismatches() {
    echo "SELECT '#', srcpath FROM audit WHERE success IS NULL;" | sqlite3 -separator "   " $AUDITDB
}

function serviced() {
    srcfile=$1
    echo "SELECT count(*) FROM audit WHERE success IS NOT NULL AND srcpath='$srcfile';" | sqlite3 $AUDITDB
}

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


maxTries=$TIMEOUT
tries=0

echoverbose "# Waiting $maxTries seconds for srcfiles to be submited: $SRCFILES"
for f in $SRCFILES; do
    echonverbose "$f($tries); "
    while [ `serviced $f` -eq "0" ]; do
	    tries=$((tries+1))
  	    echonverbose "."
	    if [ "$tries" -gt "$maxTries" ]; then
            echoverbose ""
	        echo
	        echo "# Aborted after $maxTries seconds"
	        echo "# Not serviced: $f"
	        exit 1
	    fi
	    sleep 1
    done
done
echoverbose " Done in $tries seconds"
exit 0
