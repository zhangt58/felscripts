#!/bin/bash

#
# add SDDS columns information, make input file to be sdds compatible
# genesis convention
#

filetomodi=$1
outputfile=${2:-${filetomodi}}
caption=${3:-"Phase Space"}

[ $# -lt 1 ] && echo "Usage: $0 fileToBeSDDSed" && exit 1

if [ ! -e sddshead ]
then
cat << EOF > sddshead
SDDS1
&description text="${caption}", contents="output phase space", &end
&column name=gamma,	 symbol=\$gg\$r,  units="m\$be\$nc\$a2\$n", description="momentum", format_string="%.14e", type=double,  &end
&column name=theta,  symbol=\$gq\$r,  units="rad", description="time", format_string=%.14e, type=double,  &end
&column name=x,  	 symbol=x,  units=m, description="horizontal position", format_string=%.14e, type=double,  &end
&column name=y,  	 symbol=y,  units=m, description="vertical position",   format_string=%.14e, type=double,  &end
&column name=xp,  symbol=\$gg\$gb\$r\$bx\$n, description="horizontal slop", format_string=%.14e, type=double,  &end
&column name=yp,  symbol=\$gg\$gb\$r\$by\$n, description="vertical slop",   format_string=%.14e, type=double,  &end
&data mode=ascii, no_row_counts=1,  &end
! page number 1
EOF
fi

if [ "x$1"=="x$2" ]
then
	sed "\$r ${filetomodi}" sddshead > tmp.$$
	mv tmp.$$ ${outputfile}
else
	sed "\$r ${filetomodi}" sddshead > ${outputfile}
fi

rm sddshead
