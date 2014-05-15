#!/bin/bash
#==========================================================================
#
#          FILE:  calspe.sh
# 
#         USAGE:  ./calspe.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  05/09/2011 09:21:12 PM CST
#      REVISION:  ---
#==========================================================================

specdir=$(pwd)/spectra_is_here
[[ ! -e ${specdir} ]] && mkdir -p ${specdir}

#the first script argument is defined by the user
outfile=$1

file1=${1%%.out}.recd

file2=${1%%.out}.spec


GREP=$(which grep)
#slice seperation by unit of meter
deltsli=$(${GREP} -m1 seper ${outfile} | awk '{print $1}')

#the total zrecord by unit of delz
zrecord=$(${GREP} -m1 entri ${outfile} | awk '{print $1}')

#extract the zrec-th z record from the tdp output file, or defind by the
#second shell argument
zrec=${2:-${zrecord}}

#the zrec-th output is dumped to file1
getdp_z ${outfile} ${file1} ${zrec}

#tmp file for s[m] power[W] phase[rad]
spphi="/tmp/spphi.$$"

#total number of slice
#nslice=$(grep -m1 nslice ${outfile} | awk '{print $NF}')
nslice=$(${GREP} -m1 nslice ${outfile} | awk '{print $NF}')
wvlgth=$(${GREP} -m1 wavele ${outfile} | awk '{print $1}')

awk '{printf("%6.6e %6.6e %6.6e\n",(NR-1)*'${deltsli}',$1,$4)}' ${file1} > ${spphi}
calspe.m ${spphi} ${file2} ${nslice} ${wvlgth}
#cp ${spphi} ./spphi
mv ${spphi} ${specdir}/${1%%.out}.spph
mv ${file1} ${file2} ${specdir}

