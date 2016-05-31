#!/bin/bash
#
# set up EEHG global parameters
#
#
[ $# -ne 3 ] && echo "Usage: setParams.sh npart nslice xlamds1 [m]" && exit

npart=$1
nslice=$2
xlamds1=$3

pwdir=$(pwd)

# npart for single slice
file1=${pwdir}/../0_INI/Makefile
file2=${pwdir}/../0_INI/0.in
file3=${pwdir}/../MOD/mod1/namelist1
file32=${pwdir}/../MOD/mod1/namelist2
file4=${pwdir}/../MOD/mod2/namelist2

sed -i  "8s/\(.*\)\ [0-9]*\ \(.*\)/\1 ${npart} \2/" ${file1}
sed -i "13s/\(.*\)\ [0-9]*\ \(.*\)/\1 ${npart} \2/" ${file1}
sed -i "s/npart.*/npart=${npart}/i" 				${file2}

# slice number
sed -i "10,11s/\(.*\){[0-9,.]*}\(.*\)/\1{1\.\.${nslice}}\2/" 	${file1}
sed -i "s/nslice.*/nslice=${nslice}/i" 							${file2}
sed -i "s/ntail.*/ntail=-$((nslice/2))/i" 						${file2}

# total particle number for all slices

# first seedlaser wavelength
sed -i "13s/\(.*\)\ [0-9,.,e,\-]*$/\1 ${xlamds1}/" ${file1}
#sed -i "s/\(seed_wavelength.*\)=.*\(\#.*\)/\1 = ${xlamds} \2/" ${file3}
sed -i "s/npart.*/npart = $((npart*nslice))/" ${file3}
sed -i "s/npart.*/npart = $((npart*nslice))/" ${file32}
sed -i "s/npart.*/npart = $((npart*nslice))/" ${file4}


