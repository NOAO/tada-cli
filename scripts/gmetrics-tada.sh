#!/bin/bash

opts="--type=uint16 --units=size --group=tada"
/usr/bin/gmetric $opts -n tada_inactive -v `/usr/bin/dqcli -c inactive` 
/usr/bin/gmetric $opts -n tada_active   -v `/usr/bin/dqcli -c active`
/usr/bin/gmetric $opts -n tada_records  -v `/usr/bin/dqcli -c records`
