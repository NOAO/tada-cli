#!/bin/bash
hosttype=${1:-MOUNTAIN}
if [ ! -x /usr/bin/gmetric ]; then
    exit
fi

source /opt/tada/venv/bin/activate

opts="--type=uint16 --units=size --group=tada"
personalities="pipeline-decam pipeline-mosaic3 pipeline-90prime"

for personality in $personalities; do
  #/usr/bin/gmetric $opts -n tada_inactive -v `dqcli -c inactive`
  /usr/bin/gmetric $opts -n tada_active_${personality} -v $(dqcli --list active | grep $personality | wc -l)
  #/usr/bin/gmetric $opts -n tada_records  -v `dqcli -c records`
done

exit

if [ "MOUNTAIN" = $hosttype ]; then
    # For MOUNTAIN
    val=`find /var/tada/mountain_cache -type f | wc -l`
    /usr/bin/gmetric $opts -n tada_pending_xfer -v $val
    val=`find /var/tada/mountain_stash -type f | wc -l`
    /usr/bin/gmetric $opts -n tada_stashed -v $val
else
    # For VALLEY
    val=`find /var/tada/mountain-mirror -type f | wc -l`
    /usr/bin/gmetric $opts -n tada_pending_ingest  -v $val
    val=`find /var/tada/noarchive -type f | wc -l`
    /usr/bin/gmetric $opts -n tada_noarchive  -v $val
fi


