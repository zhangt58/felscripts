#!/bin/bash

#datafile from the output of optEEHG.sh
datafile=$1

#blocksize: gridsize,
blocksize=$2

outfile=$3

# output format matlab ("mat") or gnuplot ("gnu")
format=$4

sed -n 1p ${datafile} > ${outfile}
i=2
j=0

# total line number of input datafile
linetot=$(wc -l ${datafile} | awk '{print $1}')
if [ ${format} == "mat" ]
then
	while [ $i -le ${linetot} ]
	do
		j=$((i+${blocksize}))

		# show the script processing 
#		echo -e "$i\t$j"
		
		sed -n $i,${j}p ${datafile} | sort -gk2,2 >> ${outfile}
	#	echo "" >> ${outfile}

		# move to next data block
		i=$((j+1))
	done
	sed -i 1d ${outfile}
else
	while [ $i -le ${linetot} ]
	do
		j=$((i+${blocksize}))

		# show the script processing 
#		echo -e "$i\t$j"
		
		sed -n $i,${j}p ${datafile} | sort -gk2,2 >> ${outfile}
		echo "" >> ${outfile}

		# move to next data block
		i=$((j+1))
	done
fi

