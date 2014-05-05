#!/bin/bash

#
# Calculate gaincurve (pulse energy v.s. z) from genesis tdp output file
# Created time: Nov. 2nd, 2012, 11:12 AM
# Author: Tong Zhang
#

outfile=$1
gcfile="gc.$$"
ztmp="z.tmp.$$"

zrec=$(grep -m1 'entri'  ${outfile} | awk '{print $1}' )
delz=$(grep -m1 "delz"   ${outfile} | awk '{print $NF}' | sed 's/[e,E,D,d]/\*10\^/;s/\+//')
xlamd=$(grep -m1 "xlamd" ${outfile} | awk '{print $NF}' | sed 's/[e,E,D,d]/\*10\^/;s/\+//')

echo -e "#z[m]\tpulse_energy[micronJ]" > ${gcfile}

for ((zi=1;zi<=${zrec};zi=$((zi+1))))
do
	getdp_z ${outfile} ${ztmp} ${zi}
	zz=$(echo "(${zi}-1)*${delz}*${xlamd}" | bc -l)
	awk -v z=${zz} 'BEGIN{s=0}{s+=$1}END{printf("%f\t%e\n", z,s/NR)}' ${ztmp} >> ${gcfile}
done

mv ${gcfile} ${outfile}.gc.avgp
rm ${ztmp}
