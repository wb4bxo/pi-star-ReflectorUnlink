#!/bin/bash

echo "$(date -u)-netLink.sh $1 $2" >>/var/log/pi-star/netLink.log
if [ "$1" == "unlink" ]; then
  /usr/local/sbin/pistar-link $1 $2
  rm -f /tmp/netLink.flag
else
  touch /tmp/netLink.flag
  /usr/local/sbin/pistar-link $1 $2
fi
