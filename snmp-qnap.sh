#!/usr/bin/env bash
HOST=192.168.2.250
COMMUNITY=public

disk=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.4.1 | awk '{print $4}' | sed 's/^"//')
free=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.5.1 | awk '{print $4}' | sed 's/^"//')
UNITtest=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.4.1 | awk '{print $5}' | sed 's/.*\(.B\).*/\1/')
UNITtest2=$(snmpget -v2c -c "$COMMUNITY" "$HOST" 1.3.6.1.4.1.24681.1.2.17.1.5.1 | awk '{print $5}' | sed 's/.*\(.B\).*/\1/')
    #echo $disk - $free - $UNITtest - $UNITtest2

if [ "$UNITtest" == "TB" ]; then
 factor=$(echo "scale=0; 1000000" | bc -l)
elif [ "$UNITtest" == "GB" ]; then
 factor=$(echo "scale=0; 1000" | bc -l)
else
 factor=$(echo "scale=0; 1" | bc -l)
fi

if [ "$UNITtest2" == "TB" ]; then
 factor2=$(echo "scale=0; 1000000" | bc -l)
elif [ "$UNITtest2" == "GB" ]; then
 factor2=$(echo "scale=0; 1000" | bc -l)
else
 factor2=$(echo "scale=0; 1" | bc -l)
fi

#echo $factor - $factor2
disk=$(echo "scale=0; $disk*$factor" | bc -l)
free=$(echo "scale=0; $free*$factor2" | bc -l)

#debug used=$(echo "scale=0; 9000*1000" | bc -l)
used=$(echo "scale=0; $disk-$free" | bc -l)

#echo $disk - $free - $used
PERC=$(echo "scale=0; $used*100/$disk" | bc -l)

diskF=$(echo "scale=0; $disk/$factor" | bc -l)
freeF=$(echo "scale=0; $free/$factor2" | bc -l)
usedF=$(echo "scale=0; $used/$factor" | bc -l)

#wdisk=$(echo "scale=0; $strWarning*$disk/100" | bc -l)
#cdisk=$(echo "scale=0; $strCritical*$disk/100" | bc -l)

OUTPUT="Total:"$diskF"$UNITtest - Used:"$usedF"$UNITtest - Free:"$freeF"$UNITtest2 - Used Space: $PERC%|Used=$PERC;"
echo $OUTPUT