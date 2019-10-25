#!/bin/bash

####### Some personalizations

#Callsign of the repeater or hotspot this is running on
REPEATER_CALL="WB4BXO"

#Time in seconds if exceeded will prompt a disconnect.
#Keep in mind that it can stay linked for 1 second less than 
# your poll time longer than this. I have mine run every 5
# minutes on cron so it could actually stay connected for 
# this time plus 4 minutes and 59 seconds.
INACTIVITY_TIME="3600"

##### Only test/disconnect if not linked for a net by netLink.sh
# This means you must explicitely unlink after a net using netLink.sh
# which sets and clears this flag.
if [ ! -f /tmp/netLink.flag ]; then
  ######################################################################
  # Get the Links.log to see if and when we connected to the reflector.
  # One reason is so we won't disconnect if not connected, another reason
  # is to see if we connected via the control channel instead of RF and 
  # use that time instead.
  LINKS_LOG=$(cat /var/log/pi-star/Links.log)
  if [ ${#LINKS_LOG} != 0 ]; then
    ######################################################################
    #get last RF DStar header (same as last transmit to repeater) 
    LAST_RF=$(grep "Repeater header" /var/log/pi-star/Headers.log | tail -n 1)
    LAST_RF=${LAST_RF:=0}
    echo $LAST_RF

    # Munge a bit to get times
    TIME_STAMP=${LAST_RF%: Repeater*}
    echo [$TIME_STAMP]
    TIME_T_THEN=$(date -u -d "${TIME_STAMP}" +"%s")
    echo [$TIME_T_THEN]
    TIME_T_NOW=$(date +"%s")
    echo [$TIME_T_NOW]
    TIME_T_DELTA=$(($TIME_T_NOW-$TIME_T_THEN))
    TIME_CONNECT=${LINKS_LOG%: *Type:*}
    TIME_T_LINK=$(date -u -d "${TIME_CONNECT}" +"%s")
    USING_LINK_TIME=false
    if (($TIME_T_LINK>$TIME_T_THEN)); then
      TIME_T_DELTA=$(($TIME_T_NOW-$TIME_T_LINK))
      USING_LINK_TIME=true
    fi
    #TIME_T_DELTA now has the elapsed time since either last RF or LINK time,
    # whichever is shorter.
    echo [$TIME_T_DELTA]

    MY_CALL=$(echo ${LAST_RF#*My: })
    MY_CALL=${MY_CALL% Your:*}
    echo [$MY_CALL]

    UR_CALL=$(echo ${LAST_RF#*Your: })
    UR_CALL=${UR_CALL% Rpt1:*}
    echo [$UR_CALL]

    RPT1_CALL=$(echo ${LAST_RF#*Rpt1: })
    RPT1_CALL=${RPT1_CALL% Rpt2:*}
    echo [$RPT1_CALL]

    RPT2_CALL=$(echo ${LAST_RF#*Rpt2: })
    RPT2_CALL=${RPT2_CALL% Flags:*}
    echo [$RPT2_CALL]

    # check and see if it is a call routed through the gateway
    if [ "$RPT2_CALL" == "${REPEATER_CALL} G" ] || $USING_LINK_TIME; then
      if (($TIME_T_DELTA>$INACTIVITY_TIME)); then
        # gateway call and it was longer ago than INACTIVITY_TIME
        /usr/local/sbin/pistar-link unlink
        echo "$(date)- Inactivity unlink" >>/var/log/pi-star/netLink.log
      fi
    fi
  else
    echo "Not currently linked!"
  fi
else
  echo "Flagged as a Net link, don't disconnect on inactivity!"
fi
