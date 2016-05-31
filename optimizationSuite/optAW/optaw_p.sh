#!/bin/bash

#
# optaw.sh: parallel version
# Author: Tong Zhang
# Date: Oct.30th, 2014
# 

infile="rad.in"
#sper="0.03"
#sval0="32200"
#nscan=400
fac=10000
#startpoint=$(awk -v b=${sval0} -v a=${sper} 'BEGIN{print int(b*(1-a))}')
#endpoint=$(awk -v b=${sval0} -v a=${sper} 'BEGIN{print int(b*(1+a))}')
#steppoint=$(awk -v b=${sval0} -v a=${sper} -v n=${nscan} 'BEGIN{print int(b*2*a/n)}')

startpoint=8500
endpoint=10500
steppoint=1

# seclen: undulator length for one section
seclen=120

echo $startpoint
echo $endpoint
echo $steppoint

function opt_sec()
{
	mkdir -p ./runtime/opt$1
	cp ${infile} optaw.sh ./runtime/opt$1
	cp ${infile%%.*}.lat ./runtime/opt$1 2> /dev/null
	cd ./runtime/opt$1
	start=$2
	end=$3
	step=$4
	fac=$5
    seclen=$6
	bash optaw.sh ${infile} ${start} ${end} ${step} ${fac} ${seclen}
}

totalCores=$(grep processor /proc/cpuinfo | wc -l)
Ncores=${1:-$totalCores}

Nsplit=$(echo "(${endpoint}-${startpoint})/${Ncores}" | bc)

for((i=1;i<=${Ncores};i++))
do
	echo "Fork job $i"
	par1=$((${startpoint}+(i-1)*${Nsplit}))
	par2=$((${startpoint}+i*${Nsplit}))
	par3=${steppoint}
	par4=${fac}
    par5=${seclen}
	(opt_sec $i $par1 $par2 $par3 ${par4} ${par5}) &
done
wait

eval cat runtime/opt{1..${Ncores}}/awscan.dat > awscan.dat
optaw=$(sort -gk2,2 awscan.dat | tail -1 | awk '{print $1}')
sed -i -e "s/aw0.*/aw0=${optaw}/i;s/awd.*/awd=${optaw}/i" ${infile}
sed -i "s/aw.*${seclen}.*/aw ${optaw} ${seclen} 0/i" ${infile%%.*}.lat

echo ${infile} | genesis

echo "Done"
