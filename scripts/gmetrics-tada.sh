#!/bin/bash
hosttype=${1:-MOUNTAIN}
if [ ! -x /usr/bin/gmetric ]; then
    exit
fi

source /opt/tada/venv/bin/activate

opts="--type=uint16 --units=size --group=tada"
#/usr/bin/gmetric $opts -n tada_inactive -v `/usr/bin/dqcli -c inactive` 
# McManus Testing 2017/04/24
/usr/bin/gmetric $opts -n tada_active   -v `/opt/tada/venv/bin/dqcli -c active`
#/usr/bin/gmetric $opts -n tada_records  -v `/usr/bin/dqcli -c records`

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

