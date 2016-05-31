#!/bin/bash

#
# optgamma.sh: parallel version
#

infile=$1
startpoint=$2
endpoint=$3
step=$4
fac=$5

#echo "#scan gamma0 of e-Beam"  > gammascan.dat
#echo -e "#gamma0\tpowerout[W]" >> gammascan.dat

> gammascan.dat

for (( i=${startpoint}; i<${endpoint}; i=$((i+$step)) ))
do
	gammanew=$(echo "scale=3;$i/${fac}" | bc)
	sed -i "s/\ gamma0.*/\ gamma0=$gammanew/" ${infile}
	echo "Now gamma0=${gammanew}."
	echo "${infile}" | genesis > /dev/null
	maxpower=$(getssdata ${infile%%.*}.out | sort -gk4,4 | tail -1 | awk '{print $4}')
	echo -e "${gammanew}\t${maxpower}" >> gammascan.dat
done
