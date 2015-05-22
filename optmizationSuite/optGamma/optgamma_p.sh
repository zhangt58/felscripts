#!/bin/bash

#
# optgamma.sh: parallel version
# Author: Tong Zhang
# Date: Apr.13th, 2013
# 

infile="rad.in"
#sper="0.03"
#sval0="32200"
#nscan=400
fac=100
#startpoint=$(awk -v b=${sval0} -v a=${sper} 'BEGIN{print int(b*(1-a))}')
#endpoint=$(awk -v b=${sval0} -v a=${sper} 'BEGIN{print int(b*(1+a))}')
#steppoint=$(awk -v b=${sval0} -v a=${sper} -v n=${nscan} 'BEGIN{print int(b*2*a/n)}')

startpoint=2738900
endpoint=2740550
steppoint=1

echo $startpoint
echo $endpoint
echo $steppoint

function opt_sec()
{
	mkdir -p ./runtime/opt$1
	cp ${infile} optgamma.sh ./runtime/opt$1
	cp ${infile%%.*}.lat ./runtime/opt$1 2> /dev/null
	cd ./runtime/opt$1
	start=$2
	end=$3
	step=$4
	fac=$5
	bash optgamma.sh ${infile} ${start} ${end} ${step} ${fac}
}

totalCores=$(grep processor /proc/cpuinfo | wc -l)
Ncores=${1:-$totalCores}

#Nsplit=$(echo "(${endpoint}-${startpoint})/${steppoint}/${Ncores}" | bc)
Nsplit=$(echo "(${endpoint}-${startpoint})/${Ncores}" | bc)

for((i=1;i<=${Ncores};i++))
do
	echo "Fork job $i"
	par1=$((${startpoint}+(i-1)*${Nsplit}))
	par2=$((${startpoint}+i*${Nsplit}))
	par3=${steppoint}
	par4=${fac}
	(opt_sec $i $par1 $par2 $par3 ${par4}) &
done
wait

eval cat runtime/opt{1..${Ncores}}/gammascan.dat > gammascan.dat
optgam=$(sort -gk2,2 gammascan.dat | tail -1 | awk '{print $1}')
sed -i "s/\ gamma0.*/\ gamma0=\ ${optgam}/" ${infile}
echo ${infile} | genesis

echo "Done"
