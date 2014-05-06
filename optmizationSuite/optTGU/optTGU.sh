#!/bin/bash
#
# shell script for scanning TGU parameters
#
#

startpoint=$1
endpoint=$2
step=$3

> scanTGU.dat

# eta
for((i=${startpoint};i<${endpoint};i=$((i+${step}))))
do
	itram16=$(echo "$i/10" | bc -l)
	# alpha
	for((j=0;j<=200;j=$((j+4))))
	do
		alpha=$(echo "$j" | bc -l)
		sed -i "s/itram16.*/itram16=${itram16}e-3/" rad.in
		sed -i "s/TGUalpha.*/TGUalpha=${alpha}/" rad.in
		echo -e "${itram16}\t${alpha}"
		echo rad.in | genesis > /dev/null
		powerend=$(tail -1 rad.out | awk '{print $1}')
		echo -e "${itram16}\t${alpha}\t${powerend}" >> scanTGU.dat
	done
done
