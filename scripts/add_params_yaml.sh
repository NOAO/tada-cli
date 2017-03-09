#!/bin/bash -e
# PURPOSE: 
#   Add min personality containing FILENAME, MD5SUM to dir containing FITS file.
#
cmd=`basename $0`
usage="USAGE: $cmd [options] absPathToLocalFITS"

RAC=1 # Required Argument Count
if [ $# -lt $RAC ]; then
    echo "Not enough non-option arguments. Expect at least $RAC."
    echo >&2 "$usage"
    exit 2
fi

localfits=$1

##############################################################################

md5=`md5sum ${localfits} | cut -d' ' -f1`
val=`fitsheader -k DTACQNAM -t ascii.csv psg_161230_061637_ori_tTADASMOKE.fits.fz| tail -1`
IFS=',' read -a KW <<< "$val"
origfits=${KW[3]}

cat > ${localfits}.yaml <<EOF
params:
    filename: $origfits
    md5sum: $md5
EOF

