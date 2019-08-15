#!/bin/bash
hosttype=${1:-VALLEY}
if [ ! -x /usr/bin/gmetric ]; then
    exit
fi

source /opt/tada/venv/bin/activate

opts="--type=uint16 --units=size --group=tada"
personalities="pipeline-decam pipeline-mosaic3 pipeline-90prime ct4m-decam"

for personality in $personalities; do
  /usr/bin/gmetric $opts -n tada_active_${personality} -v $(dqcli --list active | grep $personality | wc -l)
done

