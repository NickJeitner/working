#!/bin/bash

#
# Create a simple rrd data file to collect the aggregate
# current on T22. This is a one time operattion that
# will be updated using a cron job every 60sec.
#

DDIR=/home/nick.jeitner/working/monitoring

if [ -x ${DDIR}/t22amp.rrd ]; then
  	echo "Are you sure!!
	exit
fi

/usr/local/bin/rrdtool create ${DDIR}/t22amp.rrd \
	--step 60			\
	--start	$( date +%s )		\
	DS:Current:GAUGE:60:U:U	\
	RRA:AVERAGE:0.5:1:360		\
	RRA:AVERAGE:0.5:6:360		\
	RRA:AVERAGE:0.5:3:720


