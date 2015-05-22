#!/bin/bash
#
# parallel version for scanning TGU parameters
#
# Author: Tong ZHANG
# Last update time: 10:54, Mar. 16th, 2013

function opt_sec()
{
	mkdir -p ./runtime/opt$1
	cp -a rad.in 0.out.dpa optTGU.sh ./runtime/opt$1
	cp -a rad.lat ./runtime/opt$1 2> /dev/null
	cd ./runtime/opt$1
	vStart=$2
	vEnd=$3
	vStep=$4
	bash optTGU.sh ${vStart} ${vEnd} ${vStep}
}

echo 0.in | genesis > /dev/null

totalCores=$(grep processor /proc/cpuinfo | wc -l)
Ncores=${1:-$totalCores}
# eta [0.1mm]
etamax=1000
Nscan=50
Ntotal=$(echo "${etamax}" | bc -l)
Nsplit=$(echo "${Ntotal}/${Ncores}" | bc)
istep=$(echo "${Ntotal}/${Nscan}" | bc)

# eta
for((icore=1;icore<=${Ncores};icore++))
do
	echo "Fork job ${icore}"
	par1=$((1+${Nsplit}*(icore-1)))
	par2=$((1+${Nsplit}*icore))
	par3=${istep}
	(opt_sec ${icore} $par1 $par2 $par3) &
done
wait

eval cat runtime/opt{1..${Ncores}}/scanTGU.dat > scanTGU.$$.dat
rm -rf runtime
