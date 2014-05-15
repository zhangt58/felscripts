#!/bin/bash
#
# shell script for scanning Taper parameters
#
#

startpoint=$1
endpoint=$2
step=$3
wcoefz1s=$4
wcoefz3v=$5

> scanTaper.dat

# WCOEFZ[1], unit: 0.1m
for((i=${startpoint};i<${endpoint};i=$((i+${step}))))
do
	wcoefz1v=$(echo "(${wcoefz1s}+$i)*0.1" | bc -l)
	# WCOEFZ[2], unit: 0.001
	for((j=2;j<=50;j=$((j+2))))
	do
		wcoefz2v=$(echo "$j*0.001" | bc -l)
		sed -i "s/wcoefz.*/wcoefz=${wcoefz1v} ${wcoefz2v} ${wcoefz3v}/" rad.in
		echo -e "${wcoefz1v}\t${wcoefz2v}\t${wcoefz3v}"
		echo rad.in | genesis > /dev/null
		powerend=$(tail -1 rad.out | awk '{print $1}')
		echo -e "${wcoefz1v}\t${wcoefz2v}\t${wcoefz3v}\t${powerend}" >> scanTaper.dat
	done
done
