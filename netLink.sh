#!/bin/bash

echo "$(date)-netLink.sh $1 $2" >>/var/log/pi-star/netLink.log
if [ "$1" == "unlink" ]; then
  rm -f /tmp/netLink.flag
else
  touch /tmp/netLink.flag
fi
/usr/local/sbin/pistar-link $1 $2
