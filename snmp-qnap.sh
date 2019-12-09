#!/usr/bin/env bash
HOST=192.168.2.250
COMMUNITY=public

# disk total
DISK_RAW=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.4.1)
DISK_BYTES=$(echo $DISK_RAW | awk '{print $4}' | sed 's/"//')
UNIT=$(echo $DISK_RAW | awk '{print $5}' | sed 's/"//')

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
DISK_RAW=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.5.1)
DISK_BYTES=$(echo $DISK_RAW | awk '{print $4}' | sed 's/"//')
UNIT=$(echo $DISK_RAW | awk '{print $5}' | sed 's/"//')

#TODO: are we using 1000 or 1024 as scaling factor?
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
DISK_BYTES_USED_PERCENT=$(echo "$DISK_BYTES_USED * 100 / $DISK_BYTES_TOTAL" | bc)
echo $DISK_BYTES_TOTAL $DISK_BYTES_USED $DISK_BYTES_USED_PERCENT
