#!/bin/bash
#==========================================================================
#
#          FILE:  genplot.sh
# 
#         USAGE:  ./genplot.sh 
# 
#   DESCRIPTION:  generate plt file for gnuplot
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  02/17/2011 08:37:01 PM CST
#      REVISION:  ---
#==========================================================================
echo "
set terminal wxt enhanced
unset key
set grid
set xlabel \"z [m]\"
set ylabel \"FEL power [W]\"
set format y \"%2.1t{/Symbol \327}10^{%L}\"
set xtics
set mxtics
set ytics
set mytics
set style line 1 lt 3 lw 1
" > plotpz.plt

for i in `ls temppz*`
do 
	echo "$i u 1:2 w l ls 1,\\"
done | sed -e "s/\([^ ]*\)/'\1'/;\$s/..$//;1s/^/plot /" >> plotpz.plt
