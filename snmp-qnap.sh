#!/usr/bin/env bash
HOST=192.168.2.250
COMMUNITY=public

# disk total
DISK_STRING=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.4.1)
# warning: it is possible different NAS models (or even versions?) produce different output strings
# adjust awk/sed to your specific case
DISK_BYTES=$(echo $DISK_STRING | awk '{print $4}' | sed 's/"//')
UNIT=$(echo $DISK_STRING | awk '{print $5}' | sed 's/"//')

#TODO: are we using 1000 or 1024 as scaling factor?
if [ "$UNIT" == "GB" ]; then
    DISK_BYTES_TOTAL=$(echo "$DISK_BYTES * 1000^3/1" | bc)
fi
if [ "$UNIT" == "TB" ]; then
    DISK_BYTES_TOTAL=$(echo "$DISK_BYTES * 1000^4/1" | bc)
fi
if [ "$UNIT" == "PB" ]; then
    DISK_BYTES_TOTAL=$(echo "$DISK_BYTES * 1000^5/1" | bc)
fi

# disk free
DISK_STRING=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.5.1)
DISK_BYTES=$(echo $DISK_STRING | awk '{print $4}' | sed 's/"//')
UNIT=$(echo $DISK_STRING | awk '{print $5}' | sed 's/"//')

if [ "$UNIT" == "GB" ]; then
    DISK_BYTES_FREE=$(echo "$DISK_BYTES * 1000^3/1" | bc)
fi
if [ "$UNIT" == "TB" ]; then
    DISK_BYTES_FREE=$(echo "$DISK_BYTES * 1000^4/1" | bc)
fi
if [ "$UNIT" == "PB" ]; then
    DISK_BYTES_FREE=$(echo "$DISK_BYTES * 1000^5/1" | bc)
fi

DISK_BYTES_USED=$(($DISK_BYTES_TOTAL - $DISK_BYTES_FREE))
DISK_USED_PERCENT=$(echo "$DISK_BYTES_USED * 100 / $DISK_BYTES_TOTAL/1" | bc)

# temperature
TEMP_STRING=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.6.0)
TEMP_C=$(echo $TEMP_STRING | awk '{print $4}' | cut -c2-3)

# fan speed
FANSPEED_STRING=$(snmpget -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.4.1.24681.1.2.15.1.3.1)
FANSPEED_RPM=$(echo $FANSPEED_STRING | awk '{print $4}' | cut -c 2- )

UPTIME_STRING=$(snmpget -v2c -c "$COMMUNITY" "$HOST" .1.3.6.1.2.1.25.1.1.0)
UPTIME_SECONDS=$(echo $UPTIME_STRING | awk '{print $4}' | sed 's/[^0-9]//g')
UPTIME_SECONDS=$(echo "$UPTIME_SECONDS / 100" | bc)

# output
JSON_FMT='{"disk_bytes_total": %d, "disk_bytes_free": %d, "disk_bytes_used": %d, "disk_used_percent": %d,
"system_temp_c": %d, "fanspeed_rpm" : %d, "uptime_seconds": %d }\n'
printf "$JSON_FMT" $DISK_BYTES_TOTAL $DISK_BYTES_FREE $DISK_BYTES_USED $DISK_USED_PERCENT $TEMP_C $FANSPEED_RPM $UPTIME_SECONDS