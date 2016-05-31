#!/bin/bash -

#cp ../{mod,rad}.{in,lat} .

if [[ $#<6 ]]
then
	echo 'Usage: scanlat.sh QFSP QFEP QFSTP QDSP QDEP QDSTP'
	exit 0
fi

QFSP=$1
QFEP=$2
QFSTP=$3

QDSP=$4
QDEP=$5
QDSTP=$6

fac=100

if [[ ! -e ./scandatas ]]
then
	mkdir ./scandatas
fi

echo -e "#QF1[T/m]\tQF2[T/m]\tLength[m]\tPower[W]" >./scandatas/lpdatas

for (( qf=${QFSP};qf<=${QFEP};qf=$((qf+${QFSTP})) ))
do
	qfval=$(echo "scale=2;${qf}/${fac}" | bc)
	for (( qd=${QDSP};qd<=${QDEP};qd=$((qd+${QDSTP})) ))
	do
		qdval=$(echo "scale=2;${qd}/${fac}" | bc)
		if [[ ${qf} -eq 0 ]] && [[ ${qd} -eq 0 ]]
		then
			echo -e "${qfval}\t${qdval}\t0\t0" >> ./scandatas/lpdatas
			continue
		fi
		bash testsign.sh ${qfval} ${qdval} > /dev/null
		if [[ $? -eq 1 ]]
		then
			echo -e "${qfval}\t${qdval}\t0\t0" >> ./scandatas/lpdatas
			continue
		fi
		echo -e "QF:${qfval}\tQD:${qdval}"
		bash match.sh ${qfval} ${qdval} 11 13 rad.lat
		echo "mod.in" | genesis > /dev/null
		echo "rad.in" | genesis > /dev/null
		a=$(bash getpal.sh)
		satl=$(echo $a | awk '{print $1}')
		satp=$(echo $a | awk '{print $2}')
		mv temppz ./scandatas/temppz_${qfval}_${qdval}
		echo -e "${qfval}\t${qdval}\t${satl}\t${satp}" >> ./scandatas/lpdatas
	done
done
a=$(sort -g -k4,4 ./scandatas/lpdatas | tail -1)
optQF1=$(echo $a | awk '{print $1}')
optQF2=$(echo $a | awk '{print $2}')
bash match.sh ${optQF1} ${optQF2} 11 13 rad.lat
rm ${runtemp} ${input1} ${input2}
bash run
