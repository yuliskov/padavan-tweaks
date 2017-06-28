#!/usr/bin/env bash
 
log_entry=$(/opt/bin/smartctl -A /dev/sdb | egrep Temperature_Celsius | awk '{print "HDD1 TEMP: " $10}')
 
logger "$log_entry"

