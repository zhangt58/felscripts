#!/bin/bash
#==========================================================================
#
#          FILE:  reform.sh
# 
#         USAGE:  ./reform.sh 
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
#       CREATED:  07/05/2011 06:48:38 PM CST
#      REVISION:  ---
#==========================================================================

#datafile from the output of scanlat.sh
datafile=$1

#blocksize: gridsize in on dimensional,
blocksize=$2

sed -n 1p ${datafile} > fmtd
i=2
j=0
# total line number of input datafile
linetot=$(wc -l ${datafile} | awk '{print $1}')
while [ $i -le ${linetot} ]
do
	j=$((i+${blocksize}))

	# show the script processing 
	echo -e "$i\t$j"
	
	sed -n $i,${j}p ${datafile} | sort -gk2,2 >> fmtd
	
	# add blank line for gnuplt splot
	echo "" >> fmtd

	# move to next data block
	i=$((j+1))
done

