#!/bin/bash
hosttype=${1:-VALLEY}
if [ ! -x /usr/bin/gmetric ]; then
    exit
fi

source /opt/tada/venv/bin/activate

opts="--type=uint16 --units=size --group=tada"

# La Serena Intermediate Hop for DECam xfers.
if [ $(hostname) == "valls2.ctio.noao.edu" ]; then
  COUNT=$(find /var/tada/nowatch/ -type f -path "*/ct4m-decam/*" -mmin -60 | wc -l)
  /usr/bin/gmetric $opts -n ct4m-decam-xfer-laserena -v $COUNT
# Tucson dropbox and ingest for DECam. 
elif [ $(hostname) == "valtu1.sdm.noao.edu" ]; then
  COUNT=$(find /var/tada/dropbox/ -type f -path "*/ct4m-decam/*" -mmin -60 | wc -l)
  /usr/bin/gmetric $opts -n ct4m-decam-xfer-tucson-incoming -v $COUNT
  COUNT=$(dqcli --list active | grep ct4m-decam | wc -l)
  /usr/bin/gmetric $opts -n ct4m-decam-xfer-tucson-ingestbacklog -v $COUNT
else
  list="pipeline-decam pipeline-mosaic3 pipeline-90prime"
  for personality in $list; do
    DROPBOX=$(find /var/tada/dropbox/ -type f -path "*/$personality/*" -mmin -60 | wc -l)
    ACTIVE=$(dqcli --list active | grep $personality | wc -l)
    /usr/bin/gmetric $opts -n tada_dropbox_${personality} -v $DROPBOX
    /usr/bin/gmetric $opts -n tada_active_${personality} -v $ACTIVE
  done
fi




