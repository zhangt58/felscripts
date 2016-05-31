#!/bin/bash
#
# runFELs.sh: script to perform FEL time-dependent simulation 
# 			  by utilizing Genesis as a FEL radiation calculator.
#
# Author: Tong ZHANG (tzhang@sinap.ac.cn)
# Created: Jan. 28th, 2013
# Original Version: 1.0 @ Oct. 13th, 2011
# Current Version: 3.0 @ Jan. 31th, 2013
# Log: lots of
#

# 
GREP=$(which grep)
AWK=$(which awk)
SED=$(which sed)

slicePath="./mslices" 	# root path of folder which contain all slices
resultdir="EEHGdat"  	# output dir to write simulated results,
Nu=60				# total period of one undulator module
totalCharge="87e-12" 	# total bunch charge
totalNpart="10000000" 	 	# total particle number

outtmp="./output.$$" 	# dir to put temporary files
bincntfile="${slicePath}/binInfo_slice" # slicing counting information
nslice=$(${GREP} "Total slice number" ${bincntfile} | ${AWK} -F':' '{print $NF}') # total slice number
delt=$(${GREP} "Slice width" ${bincntfile} | ${AWK} -F':' '{print $NF}') # separation of slices by time (t-col)
npartfile="${outtmp}/fnpart" 		# temporary file to store npart(i)
curpeakfile="${outtmp}/fcurpeak" 	# temporary file to store curpeak(i)

starts=1 # the first slice order of simulation
#ends=
ends=$((nslice-0)) # the last slice order of simulation

infile0="./rad0.in" # input file template for genesis simulation
newinfile="./rad.in" # new input file for genesis simulation
radlat="ra1.lat"
drilat="dr1.lat"
qf0lat="F0.lat"
qf1lat="F1.lat"
qf2lat="F2.lat"

gexec="../scripts/genesis" # genesis executable, escape npart checking

runtmp="temp.$$"
trap "rm ${runtmp}" EXIT
> ${runtmp}

[ ! -e ${outtmp} ] && mkdir -p ${outtmp}
[ ! -e ${resultdir} ] && mkdir -p ${resultdir}

# define function for modifying template input file
modifile()
{
	partfile=$1
	outputfile=$2
	fieldfile=$3
	imodfld=$4
	magfile=$5
	npart=$6
	curpeak=$7
	infile0=$8
	newinfile=$9
	${SED} "s|partfile.*|partfile=\'${partfile}\'|i" ${infile0} > ${newinfile}
	${SED} -i "s|npart.*|npart=${npart}|i" 		 	${newinfile}
	${SED} -i "s|curpeak.*|curpeak=${curpeak}|i" 	${newinfile}
	${SED} -i "s|idmpfld.*|idmpfld=1|i" 			${newinfile}
	${SED} -i "s|idmppar.*|idmppar=1|i" 			${newinfile}
	${SED} -i "s|outputfile.*|outputfile=\'${outputfile}\'|i" ${newinfile}
	${SED} -i "s|maginfile.*|maginfile=\'${magfile}\'|i" 	  ${newinfile}
	if [ ${imodfld} == '1' ]
	then
		${SED} -i "s|\!fieldfile.*|fieldfile=\'${fieldfile}\'|i" ${newinfile}
	fi
}

# generate curpeak and npart files for each slices
for(( i=${starts}; i<=${ends}; i++ ))
do
	npart=$(${SED} -n $((i+5))p ${bincntfile} | ${AWK} -F':' '{print $NF}')
	curpeak=$(${AWK} 'BEGIN{print "'"${npart}"'"/"'"${totalNpart}"'"*"'"${totalCharge}"'"/"'"${delt}"'"}')
	echo -e "${i}:\t${npart}\t${curpeak}"
	echo "${npart}" 	>> ${npartfile}
	echo "${curpeak}" 	>> ${curpeakfile}
	# clear record result files
	> "${resultdir}/res${i}"
done


# FEL simulations start

# clear log file
> ${resultdir}/log

# passed period counter
pcnt=0

# t: smaller -> tail, so start from head, i.e. i: 1 -> nslice
# slicing sort convention: t-col from big to small, i.e. head to tail

# nhf: number of half-FODO, total: 3x2=6
for((nhf=1;nhf<=6;nhf++))
do
	# F1/F2 before U + 1 period U
	# Total:(11): drift(3) + QF1/QF2(4) + drift(3) + Undulator(1)
	
	# pass QF or QD + 1 period undulator
	# set correct lattice
	if [[ $((nhf%2)) == 1 ]]
	then
		latfile=${qf1lat}
		echo "#pass ${nhf} [F1]" | tee -a "${resultdir}/log"
	else
		latfile=${qf2lat}
		echo "#pass ${nhf} [F2]" | tee -a "${resultdir}/log"
	fi

	# with slippage or not in the first step 
	if [[ ${nhf} == 1 ]]
	then
		#
		# no slippage pass latfile
		#	
		latfile=${qf0lat}
		for(( j=1,i=${starts}; i<=${ends}; i++,j++ ))
		do
			npart=$(sed -n ${j}p ${npartfile})
			curpeak=$(sed -n ${j}p ${curpeakfile})
			modifile "${slicePath}/slice${i}" "${outtmp}/rad.out" 0 0 "${latfile}" ${npart} ${curpeak} ${infile0} ${newinfile}
			echo ${newinfile} | ${gexec} >> ${runtmp}
			tail -11 "${outtmp}/rad.out" >> "${resultdir}/res${i}"
			mv "${outtmp}/rad.out.dpa" "${outtmp}/slice${i}.dpa"
			mv "${outtmp}/rad.out.dfl" "${outtmp}/slice${i}.dfl"
			pcnt=$((pcnt+1))
		done
		echo ${pcnt}
	else	
		# slippage 1 period (drift)
		for(( j=1,i=${starts}; i<${ends}; i++,j++ ))
		do
			  npart=$(sed -n ${j}p ${npartfile})
			curpeak=$(sed -n ${j}p ${curpeakfile})
			modifile "${outtmp}/slice${i}.dpa" "${outtmp}/rad.out" "${outtmp}/slice$((i+1)).dfl" 1 "${drilat}" ${npart} ${curpeak} ${infile0} ${newinfile}
			echo ${newinfile} | ${gexec} >> ${runtmp}
			tail -1 "${outtmp}/rad.out" >> "${resultdir}/res${i}"
			mv "${outtmp}/rad.out.dpa" "${outtmp}/slice${i}.dpa"
			mv "${outtmp}/rad.out.dfl" "${outtmp}/slice${i}.dfl"
			pcnt=$((pcnt+1))
		done
		# last slice (on the tail)
		  npart=$(sed -n ${j}p ${npartfile})
		curpeak=$(sed -n ${j}p ${curpeakfile})
		modifile "${outtmp}/slice${ends}.dpa" "${outtmp}/rad.out" 0 0 "${drilat}" ${npart} ${curpeak} ${infile0} ${newinfile}
		echo ${newinfile} | ${gexec} >> ${runtmp}
		tail -1 "${outtmp}/rad.out" >> "${resultdir}/res${ends}"
		mv "${outtmp}/rad.out.dpa" "${outtmp}/slice${ends}.dpa"
		mv "${outtmp}/rad.out.dfl" "${outtmp}/slice${ends}.dfl"
		pcnt=$((pcnt+1))

		# pass latfile-1drift+1undulator, no slippage
		for(( j=1,i=${starts}; i<=${ends}; i++,j++ ))
		do
			npart=$(sed -n ${j}p ${npartfile})
			curpeak=$(sed -n ${j}p ${curpeakfile})
			modifile "${outtmp}/slice${i}.dpa" "${outtmp}/rad.out" "${outtmp}/slice${i}.dfl" 1 "${latfile}" ${npart} ${curpeak} ${infile0} ${newinfile}
			echo ${newinfile} | ${gexec} >> ${runtmp}
			tail -10 "${outtmp}/rad.out" >> "${resultdir}/res${i}"
			mv "${outtmp}/rad.out.dpa" "${outtmp}/slice${i}.dpa"
			mv "${outtmp}/rad.out.dfl" "${outtmp}/slice${i}.dfl"
			pcnt=$((pcnt+1))
		done	
		echo ${pcnt}
	fi

	# pass undulator, slippage Nu-1 periods
	for(( slp=1; slp<${Nu}; slp++ ))
	do
		echo "#pass ${nhf}/$((slp+1)) periods [U]" | tee -a "${resultdir}/log"
		for(( j=1,i=${starts}; i<${ends}; i++,j++ ))
		do
			  npart=$(sed -n ${j}p ${npartfile})
			curpeak=$(sed -n ${j}p ${curpeakfile})
			modifile "${outtmp}/slice${i}.dpa" "${outtmp}/rad.out" "${outtmp}/slice$((i+1)).dfl" 1 "${radlat}" ${npart} ${curpeak} ${infile0} ${newinfile}
			echo ${newinfile} | ${gexec} >> ${runtmp}
			tail -1 "${outtmp}/rad.out" >> "${resultdir}/res${i}"
			mv "${outtmp}/rad.out.dpa" "${outtmp}/slice${i}.dpa"
			mv "${outtmp}/rad.out.dfl" "${outtmp}/slice${i}.dfl"
			pcnt=$((pcnt+1))
		done
		# last slice (on the tail)
		  npart=$(sed -n ${j}p ${npartfile})
		curpeak=$(sed -n ${j}p ${curpeakfile})
		modifile "${outtmp}/slice${ends}.dpa" "${outtmp}/rad.out" 0 0 "${radlat}" ${npart} ${curpeak} ${infile0} ${newinfile}
		echo ${newinfile} | ${gexec} >> ${runtmp}
		tail -1 "${outtmp}/rad.out" >> "${resultdir}/res${ends}"
		mv "${outtmp}/rad.out.dpa" "${outtmp}/slice${ends}.dpa"
		mv "${outtmp}/rad.out.dfl" "${outtmp}/slice${ends}.dfl"
		pcnt=$((pcnt+1))
		echo ${pcnt}
	done
done
