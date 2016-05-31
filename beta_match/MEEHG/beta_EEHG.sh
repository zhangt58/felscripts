#!/bin/bash
#==========================================================================
#
#          FILE:  beta_EEHG.sh
# 
#         USAGE:  beta_EEHG.sh QF QD 
# 
#   DESCRIPTION:  this script used to collect data from GENESIS *.in and
#				*.lat for running script beta_script.m to find matched
#				twiss parameters for modulator and radiator setup in EEHG.
# 
#       OPTIONS:  need file fullat.EEHG
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  03/06/2011 07:58:39 PM CST
#      REVISION:  21:29, Jan. 19th, 2013
#==========================================================================
function creat_template()
{
cat <<EOF > fullat.EEHG
# Today is $(date)
#
# This file is a series of number separated by blanks, 
# which describes the whole lattice of EEHG.
#
# Format :!	n1	n2	n3	n4	n5	n6	n7	n8  n9  n10 n11 n12
# meaning:	lo1 lm1 lo2 lo3	lm2	lo4 lo5 lqf lo6 lur lo7 lqd
# lo1:	drift length before mod-1,						unit: mod-1 period
# lm1:	total length of mod-1,							unit: mod-1 period
# lo2:	drift length between mod-1 and chicane-1,		unit: mod-1 period
# lo3:	drift length before mod-2,						unit: mod-2 period
# lm2:	total length of mod-2,							unit: mod-2 period
# lo4:	drift length between mod-2 and chicane-2,		unit: mod-2 period
# lo5:  drift length before QF1,after chicane-2,		unit: rad period
# lqf:  1st quadruplole length,							unit: rad period
# lo6:  drift length between QF1 and undulator,			unit: rad period
# lur:  section length of undulator,					unit: rad period
# lo7:  drift length between undulator and QF2(QD),		unit: rad period
# lqd:  2nd quadruplole length,							unit: rad period
# the full lattice will be:
# n1->n2->n3->[Chi-1]->n4->n5->n6->[Chi-2]->n7->n8->n9->n10->n11->n12
# O1->M1->O2->[Chi-1]->O3->M2->O4->[Chi-2]->O5->QF->O6->UR-->O7-->QD
# Theoretically : one FODO will be: n8/2 n9 n10 n11 n12 n9 n10 n11 n8/2 
# schematic optics:
|----|  |----|  |----|    _______    |----|  |----|  |----|    _______     
|-O1-|->|-M1-|->|-O2-|-->/[Chi-1]\-->|-O3-|->|-M2-|->|-O4-|-->/[Chi-2]\-->
|----|  |----|  |----|               |----|  |----|  |----|                

     |----|  |----|  |----|  |----|  |----|  |----|
---->|-O5-|->|-QF-|->|-O6-|->|-UR-|->|-O7-|->|-QD-|-->... 
     |----|  |----|  |----|  |----|  |----|  |----|
# write lattice number from mod1 to rad after '!' the next line.
!
EOF
echo "Please fill the file fullat.EEHG, and run $0 again."
}

if [ ! -e fullat.EEHG ]
then
	creat_template
	exit 1
fi
  a=$(grep ^! fullat.EEHG | sed 's/!//')
lo1=$(echo $a | awk '{print $1}')
lm1=$(echo $a | awk '{print $2}')
lo2=$(echo $a | awk '{print $3}')
lo3=$(echo $a | awk '{print $4}')
lm2=$(echo $a | awk '{print $5}')
lo4=$(echo $a | awk '{print $6}')
lo5=$(echo $a | awk '{print $7}')
lqf=$(echo $a | awk '{print $8}')
lo6=$(echo $a | awk '{print $9}')
lur=$(echo $a | awk '{print $10}')
lo7=$(echo $a | awk '{print $11}')
lqd=$(echo $a | awk '{print $12}')

gamma0=$(grep -i gamma mod1.in    | awk -F'=' '{print $NF}')
 emitn=$(grep -i emitx mod1.in    | awk -F'=' '{print $NF}')
if [ -e mod1.lat ]
then
	   am1=$(grep -i aw   mod1.lat | awk        '{print $2}')
  lambdam1=$(grep -i unit mod1.lat | awk -F'=' '{print $NF}')
else
	   am1=$(grep -i aw0   mod1.in | awk -F'=' '{print $NF}')
  lambdam1=$(grep -i xlamd mod1.in | grep -iv xlamds | awk -F'=' '{print $NF}')
fi

if [ -e mod2.lat ]
then
	   am2=$(grep -i aw   mod2.lat | awk        '{print $2}')
  lambdam2=$(grep -i unit mod2.lat | awk -F'=' '{print $NF}')
else
	   am2=$(grep -i aw0   mod2.in | awk -F'=' '{print $NF}')
  lambdam2=$(grep -i xlamd mod2.in | grep -iv xlamds | awk -F'=' '{print $NF}')
fi

  imagl1=$(grep -i imagl mod2.in  | awk -F'=' '{print $NF}')
  idril1=$(grep -i idril mod2.in  | awk -F'=' '{print $NF}')
ibfield1=$(grep -i ibfie mod2.in  | awk -F'=' '{print $NF}')

  imagl2=$(grep -i imagl rad.in   | awk -F'=' '{print $NF}')
  idril2=$(grep -i idril rad.in   | awk -F'=' '{print $NF}')
ibfield2=$(grep -i ibfie rad.in   | awk -F'=' '{print $NF}')



lambdau=$(grep -i unit  rad.lat  | awk -F'=' '{print $NF}')
     au=$(grep -i aw0   rad.in   | awk -F'=' '{print $NF}')

QF=$1
QD=$2
octave -qf beta_script.m ${QF} ${QD} ${gamma0} ${emitn} ${lambdam1} ${am1} ${lambdam2} ${am2} ${imagl1} ${idril1} ${ibfield1} ${imagl2} ${idril2} ${ibfield2} ${lambdau} ${au} ${lo1} ${lm1} ${lo2} ${lo3} ${lm2} ${lo4} ${lo5} ${lqf} ${lo6} ${lur} ${lo7} ${lqd}
