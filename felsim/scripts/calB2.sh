#!/bin/bash
#
# calculate B2 and R562
#

r562=$(sddsprintout chi2.mat -col=R56 | tail -1)
echo -e "R562\t=${r562}"

B2=$(sddsprintout chi2.mat -col=R56 | tail -1 | \
			awk '{print $1*2*3.14159265358/523.5e-9*5e-5}')
echo -e "B2\t= ${B2}"
