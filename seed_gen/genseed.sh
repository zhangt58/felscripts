#!/bin/bash
#==========================================================================
#
#          FILE:  genseed.sh
# 
#         USAGE:  ./genseed.sh 
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
#       CREATED:  03/02/2011 03:18:51 PM CST
#      REVISION:  ---
#==========================================================================
powermax=$1
#laser power in W
seedfile=$2
#seedfile name
zoffset=$3
#zoffset unit: meter

./genseedscript.m ${powermax} 2.5 ${zoffset} ${seedfile}
size=$(wc -l < ${seedfile})
sed -i "1i\?columns zpos prad0 zrayl zwaist\n$i${size}" ${seedfile}
