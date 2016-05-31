#!/bin/bash
#==========================================================================
#
#          FILE:  match.sh
# 
#         USAGE:  ./match.sh 
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
#       CREATED:  02/16/2011 10:13:09 PM CST
#      REVISION:  22:25, Jan. 19th, 2013
#==========================================================================
if [[ $#<5 ]]
then
	echo "Warning!Not enough parameters!"
	echo "Usage: match.sh QF1 QF2 #QF1 #QF2 LatticeFile"
	echo "Now apply default setting!"
	echo "match.sh QF1 QF2 11 13 rad.lat"
fi

beammatch()
{
	QF1=$1
	QF2=$2
	mod1in=$3
	mod2in=$4
	radin=$5
	a=$(bash beta_EEHG.sh ${QF1} ${QF2} | awk -F'=' '{print $NF}')
	alphaxr=$(echo $a | awk '{print $1}')
	alphayr=$(echo $a | awk '{print $2}')
	sigmaxr=$(echo $a | awk '{print $3}')
	sigmayr=$(echo $a | awk '{print $4}')

	alphaxm2=$(echo $a | awk '{print $5}')
	alphaym2=$(echo $a | awk '{print $6}')
	sigmaxm2=$(echo $a | awk '{print $7}')
	sigmaym2=$(echo $a | awk '{print $8}')

	alphaxm1=$(echo $a | awk '{print $9}')
	alphaym1=$(echo $a | awk '{print $10}')
	sigmaxm1=$(echo $a | awk '{print $11}')
	sigmaym1=$(echo $a | awk '{print $12}')
	sed -i "s/rxbeam.*/rxbeam= ${sigmaxr}/" ${radin}
	sed -i "s/rybeam.*/rybeam= ${sigmayr}/" ${radin}
	sed -i "s/alphax.*/alphax= ${alphaxr}/" ${radin}
	sed -i "s/alphay.*/alphay= ${alphayr}/" ${radin}

	sed -i "s/rxbeam.*/rxbeam= ${sigmaxm1}/" ${mod1in}
	sed -i "s/rybeam.*/rybeam= ${sigmaym1}/" ${mod1in}
	sed -i "s/alphax.*/alphax= ${alphaxm1}/" ${mod1in}
	sed -i "s/alphay.*/alphay= ${alphaym1}/" ${mod1in}

	sed -i "s/rxbeam.*/rxbeam= ${sigmaxm2}/" ${mod2in}
	sed -i "s/rybeam.*/rybeam= ${sigmaym2}/" ${mod2in}
	sed -i "s/alphax.*/alphax= ${alphaxm2}/" ${mod2in}
	sed -i "s/alphay.*/alphay= ${alphaym2}/" ${mod2in}
}

QF1=$1
QF2=$2
LNUMQF1=${3:-11}
LNUMQF2=${4:-13}
latfile=${5:-rad.lat}
temp=/tmp/temp.$$
beammatch ${QF1} ${QF2} mod1.in mod2.in rad.in
awk '{if(NR=="'"${LNUMQF1}"'"){$2="'"${QF1}"'";printf("%-7s%+6.5E%6d%4d\n",$1,$2,$3,$4)}else print}' ${latfile} > ${temp}
mv ${temp} ${latfile}
awk '{if(NR=="'"${LNUMQF2}"'"){$2="'"${QF2}"'";printf("%-7s%+6.5E%6d%4d\n",$1,$2,$3,$4)}else print}' ${latfile} > ${temp}
mv ${temp} ${latfile}
