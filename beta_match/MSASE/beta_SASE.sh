#!/bin/bash
#==========================================================================
#
#          FILE:  beta_HGHG.sh
# 
#         USAGE:  beta_HGHG.sh QF QD 
# 
#   DESCRIPTION:  this script used to collect data from GENESIS *.in and
#				*.lat for running script beta_scriptSASE.m to find matched
#				twiss parameters for modulator and radiator setup in HGHG.
# 
#       OPTIONS:  need file fullat.hghg
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  03/06/2011 07:58:39 PM CST
#      REVISION:  ---
#==========================================================================
function creat_template()
{
cat <<EOF > fullat.SASE
#Today is $(date)
#
#This file is a series of number separated by blanks, 
#which describes the whole lattice of SASE.
#
#Format :!	n1	n2	n3	n4	n5	n6
#meaning:	lo1 QF  lo2 lur	lo3 QD
#lo1:   drift length before QF1, 					unit: radiator  period
#QF :   1st quadruplole length,						unit: radiator  period
#lo2:   drift length between QF1 and undulator,		unit: radiator  period
#UR :   undulator length,							unit: radiator  period
#lo3:   drift length between undulator and QF2,		unit: radiator  period
#QD :   2nd quadruplole length,						unit: radiator  period
#the full lattice will be: n1 n2 n3 n4 n5 n6 n7 n8 n9
#i.e.                    : O1+QF+O2+UR+O3+QD+O4+UR+O5+...
#On theory : one FODO will be: n2/2 (n3 n4 n5) n6 (n7 n8 n9) n10/2
|----|  |----|  |----|  |----|  |----|  |----|
|-O1-|->|-QF-|->|-O2-|->|-UR-|->|-O3-|->|-QD-|+... 
|----|  |----|  |----|  |----|  |----|  |----|
#write lattice number from modulator to radiator after '!' the next line.
!
EOF
echo "Please fill the file fullat.hghg, and rerun $0 again."
}

if [ ! -e fullat.SASE ]
then
	creat_template
	exit 1
fi
  a=$(grep ^! fullat.SASE | sed 's/!//')
lo1=$(echo $a | awk '{print $1}')
 lf=$(echo $a | awk '{print $2}')
lo2=$(echo $a | awk '{print $3}')
lur=$(echo $a | awk '{print $4}')
lo3=$(echo $a | awk '{print $5}')
 ld=$(echo $a | awk '{print $6}')

 gamma0=$(grep -i gamma rad.in   | awk -F'=' '{print $NF}')
  emitn=$(grep -i emitx rad.in   | awk -F'=' '{print $NF}')
lambdau=$(grep -i unit  rad.lat  | awk -F'=' '{print $NF}')
     au=$(grep -i aw0   rad.in   | awk -F'=' '{print $NF}')

QF=$1
QD=$2
./beta_scriptSASE.m ${QF} ${QD} ${gamma0} ${emitn} ${lambdau} ${au} ${lo1} ${lf} ${lo2} ${lur} ${lo3} ${ld}
