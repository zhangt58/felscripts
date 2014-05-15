#!/bin/bash
#
# parallel version for scanning Taper parameters: WCOEFZ[1] and WCOEFZ[2]
# WCOEFZ[3] = 1 or 2 define taper type, linear or quadratic.
#
# Author: Tong ZHANG
# Last update time: 19:26, May 12th, 2014

function opt_sec()
{
	mkdir -p ./runtime/opt$1
	cp -a rad.in optTaper.sh ./runtime/opt$1
	cp -a rad.lat ./runtime/opt$1 2> /dev/null
	cd ./runtime/opt$1
	vStart=$2
	vEnd=$3
	vStep=$4
	vTaps=$5
	vTapt=$6
	bash optTaper.sh ${vStart} ${vEnd} ${vStep} ${vTaps} ${vTapt}
}

totalCores=$(grep processor /proc/cpuinfo | wc -l)
Ncores=${1:-$totalCores}
# define taper type, WCOEFZ[3], 1 or 2
WCOEFZ3v=1
# define start value of WCOEFZ[1], unit: 0.1m
WCOEFZ1s=700
# define WCOEFZ[1] range, unit: 0.1m
wcoefz1r=100
Nscan=50
Ntotal=$(echo "${wcoefz1r}" | bc -l)
Nsplit=$(echo "${Ntotal}/${Ncores}" | bc)
istep=$(echo "${Ntotal}/${Nscan}" | bc)

# WCOEFZ[1]
for((icore=1;icore<=${Ncores};icore++))
do
	echo "Fork job ${icore}"
	par1=$((1+${Nsplit}*(icore-1)))
	par2=$((1+${Nsplit}*icore))
	par3=${istep}
	par4=${WCOEFZ1s}
	par5=${WCOEFZ3v}
	(opt_sec ${icore} $par1 $par2 $par3 $par4 $par5) &
done
wait

eval cat runtime/opt{1..${Ncores}}/scanTaper.dat > scanTaper.$$.dat
rm -rf runtime
