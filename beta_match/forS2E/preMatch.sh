#!/bin/bash

twisspara=$(sddsprintout chi2.twi -col=alphax -col=betax -col=alphay -col=betay | tail -1)
alphax0=$(echo ${twisspara} | awk '{print $1}')
betax0=$(echo ${twisspara}  | awk '{print $2}')
alphay0=$(echo ${twisspara} | awk '{print $3}')
betay0=$(echo ${twisspara}  | awk '{print $4}')

# undulator setup from FODO
alphax1="0.5"
betax1="3.0"
alphay1="0.1"
betay1="3.0"
distfile="ds2.dist"
newdist="newds2.dist"
nline=$(wc -l < ${distfile})
./preMatch.m ${distfile} ${newdist} ${alphax1} ${betax1} ${alphay1} ${betay1} ${alphax0} ${betax0} ${alphay0} ${betay0} ${nline}
