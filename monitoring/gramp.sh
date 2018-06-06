#!/bin/bash

#
# Generate a PNG image file showing the AMP load average since
# data started being collected. Specific times can be specified
# by calculating sec since epoch:
#	date --date="12:00:00" +%s
#

DDIR=/home/nick.jeitner/working/monitoring
GRP=/data/images/current.png
START=1528210100
END=$(( $(date +%s) - 30 ))

PERIOD="-s ${START} -e ${END}"
SIZE="-w 962 -h 282"
ARGS="${PERIOD} ${SIZE}"

#/usr/local/bin/rrdtool fetch -s ${START} -e ${END} ${DDIR}/t22amp.rrd LAST;

/usr/local/bin/rrdtool graph ${GRP} ${ARGS}	\
         DEF:current=${DDIR}/t22amp.rrd:Current:AVERAGE        \
         LINE2:current#FF0000 
