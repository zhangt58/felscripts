#!/bin/bash
#==========================================================================
#
#          FILE:  beta_HGHG.sh
# 
#         USAGE:  beta_HGHG.sh QF QD 
# 
#   DESCRIPTION:  this script used to collect data from GENESIS *.in and
#				*.lat for running script beta_script.m to find matched
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
cat <<EOF > fullat.hghg
#Today is $(date)
#
#This file is a series of number separated by blanks, 
#which describes the whole lattice of HGHG.
#
#Format :!	n1	n2	n3	n4	n5	n6	n7	n8	n9
#meaning:	lo1	lum	lo2 lo3 QF  lo4 lur	lo5 QD
#lo1:	drift length before modulator,				unit: modulator period
#UM :	modulator length,							unit: modulator period
#lo2:	drift length between modulator and chicane,	unit: modulator period
#lo3:   drift length before QF1,after chicane,		unit: radiator  period
#QF :   1st quadruplole length,						unit: radiator  period
#lo4:   drift length between QF1 and undulator,		unit: radiator  period
#UR :   undulator length,							unit: radiator  period
#lo5:   drift length between undulator and QF2(QD),	unit: radiator  period
#QD :   2nd quadruplole length,						unit: radiator  period
#the full lattice will be: n1 n2 n3 [chicane] n4 n5 n6 n7 n8 n9 n6 n7 n8
#i.e.                    : O1+UM+O2+[Chicane]+O3+QF+O4+UR+O5+QD+O4+Ur+O5
#On theory : one FODO will be: n5/2 n6 n7 n8 n9 n6 n7 n8 n5/2
|----|  |----|  |----|   |----|  |----|  |----|  |----|  |----|  |----|
|-O1-|->|-UM-|->|-O2-|-C-|-O3-|->|-QF-|->|-O4-|->|-UR-|->|-O5-|->|-QD-|+... 
|----|  |----|  |----|   |----|  |----|  |----|  |----|  |----|  |----|
#write lattice number from modulator to radiator after '!' the next line.
!
EOF
echo "Please fill the file fullat.hghg, and rerun $0 again."
}

if [ ! -e fullat.hghg ]
then
	creat_template
	exit 1
fi
  a=$(grep ^! fullat.hghg | sed 's/!//')
lo1=$(echo $a | awk '{print $1}')
lum=$(echo $a | awk '{print $2}')
lo2=$(echo $a | awk '{print $3}')
lo3=$(echo $a | awk '{print $4}')
 lf=$(echo $a | awk '{print $5}')
lo4=$(echo $a | awk '{print $6}')
lur=$(echo $a | awk '{print $7}')
lo5=$(echo $a | awk '{print $8}')
 ld=$(echo $a | awk '{print $9}')

gamma0=$(grep -i gamma mod.in    | awk -F'=' '{print $NF}')
 emitn=$(grep -i emitx mod.in    | awk -F'=' '{print $NF}')
#if [ -e mod.lat ]
#then
#	   am=$(grep -i aw   mod.lat | awk        '{print $2}')
#  lambdam=$(grep -i unit mod.lat | awk -F'=' '{print $NF}')
#else
	   am=$(grep -i aw0   mod.in | awk -F'=' '{print $NF}')
  lambdam=$(grep -i xlamd mod.in | grep -iv xlamds | awk -F'=' '{print $NF}')
#fi

  imagl=$(grep -i imagl rad.in   | awk -F'=' '{print $NF}')
  idril=$(grep -i idril rad.in   | awk -F'=' '{print $NF}')
ibfield=$(grep -i ibfie rad.in   | awk -F'=' '{print $NF}')

lambdau=$(grep -i unit  rad.lat  | awk -F'=' '{print $NF}')
     au=$(grep -i aw0   rad.in   | awk -F'=' '{print $NF}')

QF=$1
QD=$2
octave -qf beta_script.m ${QF} ${QD} ${gamma0} ${emitn} ${lambdam} ${am} ${imagl} ${idril} ${ibfield} ${lambdau} ${au} ${lo1} ${lum} ${lo2} ${lo3} ${lf} ${lo4} ${lur} ${lo5} ${ld}
