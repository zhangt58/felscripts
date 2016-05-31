#!/bin/bash
#==========================================================================
#
#          FILE:  getpal.sh
# 
#         USAGE:  ./getpal.sh 
# 
#   DESCRIPTION:  get power and length at satuation point of HGHG output
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  02/17/2011 10:23:11 AM CST
#      REVISION:  ---
#==========================================================================

outfile=${1:-rad.out}
lp=$(getssdata ${outfile} | awk '{print $1,$4}' | tee temppz | sort -gk2,2 | tail -1)
satl=$(echo ${lp} | awk '{print $1}')
satp=$(echo ${lp} | awk '{print $2}')
echo -e "$satl\t$satp"
