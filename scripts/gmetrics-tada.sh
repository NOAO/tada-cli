#!/bin/bash
hosttype=${1:-VALLEY}
if [ ! -x /usr/bin/gmetric ]; then
    exit
fi

source /opt/tada/venv/bin/activate

opts="--type=uint16 --units=size --group=tada"
list="pipeline-decam pipeline-mosaic3 pipeline-90prime"

for personality in $list; do

  DROPBOX=$(find /var/tada/dropbox/ -type f -path "*/$personality/*" -mmin -60 | wc -l)
  ACTIVE=$(dqcli --list active | grep $personality | wc -l)

  /usr/bin/gmetric $opts -n tada_dropbox_${personality} -v $DROPBOX
  /usr/bin/gmetric $opts -n tada_active_${personality} -v $ACTIVE

done

list="ct4m-decam"
for personality in $list; do

  NOWATCH=$(find /var/tada/nowatch/ -type f -path "*/$personality/*" -mmin -60 | wc -l)
  DROPBOX=$(find /var/tada/dropbox/ -type f -path "*/$personality/*" -mmin -60 | wc -l)
  ACTIVE=$(dqcli --list active | grep $personality | wc -l)

  /usr/bin/gmetric $opts -n tada_nowatch_${personality} -v $NOWATCH
  /usr/bin/gmetric $opts -n tada_dropbox_${personality} -v $DROPBOX
  /usr/bin/gmetric $opts -n tada_active_${personality} -v $ACTIVE

done
