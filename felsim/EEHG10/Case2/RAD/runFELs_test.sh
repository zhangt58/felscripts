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

slicePath="./csrslices" 	# root path of folder which contain all slices
resultdir="EEHGdat_csr_test"  	# output dir to write simulated results,
Nu=60				# total period of one undulator module
totalCharge="90e-12" 	# total bunch charge
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
