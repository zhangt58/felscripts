#!/bin/bash
#  convert sdds binary output into ascii format
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  05/10/2011 09:35:29 PM CST
#      REVISION:  21:43, Dec. 18, 2012
#==========================================================================

eleout=$1
distfile=${eleout%%.*}.dist
sddsprintout ${eleout} ${distfile} \
 -colu=t,format=%20.16E \
 -colu=p,format=%20.16E \
 -colu=x,format=%20.16E \
 -colu=y,format=%20.16E \
 -col=xp,format=%20.16E \
 -col=yp,format=%20.16E \
 -spreadsheet=nolabels,delimiter="  "  \
 -notitle

#sed -i "1i\? SIZE = 2000000\n? CHARGE = 1e-9\n? VERSION = 1.0\n? COLUMNS X PX Y PY T P" ${distfile}
