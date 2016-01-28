<<UNDER CONSTRUCTION>>
#!/bin/bash -e
# PURPOSE: rsync directory of FITS files with extra personalties to mtn dropbox
#
# EXAMPLE:
#

cmd=`basename $0`
dir=`dirname $0`

SCRIPT=$(readlink -f $0)      #Absolute path to this script
SCRIPTPATH=$(dirname $SCRIPT) #Absolute path this script is in

# Error codes
BAD_PERSONALITY=5

VERBOSE=0
MTNHOST="mtnkp.pat.sdm.noao.edu"  # NB: on PAT
RPWD="~/.tada/rsync.pwd"

usage="USAGE: $cmd [options] [reportFile]
OPTIONS:
  -m <host>:: Name of mountain host containing dropbox (default=$MTNHOST)
  -p <pwdfile>: file containing rsynd password (default=$RPWD)
  -v <verbosity>:: higher number for more output (default=$VERBOSE)

"

while getopts "hm:p:v:y:" opt; do
    echo "opt=<$opt>"
    case $opt in
	    h)
            echo "$usage"
            exit 1
            ;;
        m)
            MTNHOST=$OPTARG # FQN of mtn host containing dropbox
            ;;
        p)
            RPWD=$OPTARG 
            ;;
        v)
            VERBOSE=$OPTARG
            ;;
        y)
	        # appends to $PERSLIST
            if [ -f $OPTARG ]; then
                PERSLIST="${PERSLIST} $OPTARG"
            else
		        echo "ERROR: File given as -y option ($OPTARG) not found or not a regular file. Aborting!"  1>&2
		        exit $BAD_PERSONALITY
            fi
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


echo "MTNHOST=$MTNHOST"
echo "VERBOSE=$VERBOSE"
echo "Remaining arguments:"
for arg do echo '--> '"\`$arg'" ; done

srcdir=$1

##############################################################################

# FITS to dropbox
rsync -az --password-file $RPWD $srcdir tada@$MTNHOST::dropbox

# Personalities to dropbox
#! rsync -az --password-file $RPWD $PERSLIST tada@$MTNHOST::dropbox/$date/$instr
