#!/bin/bash

#
# Update the T22 rrd data file using the SNMP OID for the
# aggregate current. No point in doing anything more as
# the servers are supplied by a satelite PDU which feeds
# multiple servers.
# This is run via cron every 60 seconds.
#

DDIR=/home/nick.jeitner/working/monitoring
OID=SNMPv2-SMI::enterprises.21317.1.3.2.2.2.1.3.1.2.1
PDU=172.20.37.2
COMM=administrator

current=$( snmpget -v 1 -c ${COMM} ${PDU} ${OID} | awk '{gsub(/\"/,"");print $NF}' )
/usr/local/bin/rrdtool update ${DDIR}/t22amp.rrd "$( date +%s ):${current}"
