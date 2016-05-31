#!/bin/bash
#
# calculate B1 and R561
#

r561=$(sddsprintout chi1.mat -col=R56 | tail -1)
echo -e "R561\t=${r561}"

B1=$(sddsprintout chi1.mat -col=R56 | tail -1 | \
			awk '{print $1*2*3.14159265358/523.5e-9*5e-5}')
echo -e "B1\t= ${B1}"
