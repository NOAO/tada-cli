#!/bin/bash -e
# PURPOSE: 
#   Add min personality containing FILENAME, MD5SUM to dir containing FITS file.
#
# EXAMPLE:
#  find `pwd` -name "*.fits.fz" -exec scripts/add_params_yaml.sh {} \;
#  find `pwd` -name "*.yaml" -exec grep DTACQNAM {} \;
#  find `pwd` -name "*.yaml" -exec grep overwrite {} \;

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

yaml=${localfits}.yaml
echo "Creating YAML: ${yaml}"

md5=`md5sum ${localfits} | cut -d' ' -f1`
val=`fitsheader -k DTACQNAM -t ascii.csv ${localfits} | tail -1` 
IFS=',' read -a KW <<< "$val"
dtacqnam=${KW[3]}
origfits=${dtacqnam:-$localfits}

cat > ${yaml} <<EOF
options:
    DTACQNAM: $origfits
params:
    filename: $origfits
    md5sum: $md5
    overwrite: True
EOF

