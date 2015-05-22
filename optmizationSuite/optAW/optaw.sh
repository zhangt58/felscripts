#!/bin/bash

#
# optgamma.sh: parallel version
#

infile=$1
startpoint=$2
endpoint=$3
step=$4
fac=$5
seclen=$6

#echo "#scan aw of undulator"  > awscan.dat
#echo -e "#aw\tpowerout[W]" >> awscan.dat

> awscan.dat

for (( i=${startpoint}; i<${endpoint}; i=$((i+$step)) ))
do
	awnew=$(echo "scale=4;$i/${fac}" | bc)
	sed -i -e "s/aw0.*/aw0=${awnew}/i;s/awd.*/awd=${awnew}/i" ${infile}
    sed -i "s/aw.*${seclen}.*/aw ${awnew} ${seclen} 0/i" ${infile%%.*}.lat
	echo "Now aw=${awnew}."
	echo "${infile}" | genesis > /dev/null
	maxpower=$(getssdata ${infile%%.*}.out | sort -gk4,4 | tail -1 | awk '{print $4}')
	echo -e "${awnew}\t${maxpower}" >> awscan.dat
done
