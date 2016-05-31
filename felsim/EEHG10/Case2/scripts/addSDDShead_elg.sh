#!/bin/bash

#
# add SDDS columns information, make input file to be sdds compatible
# elegant convention
#

filetomodi=$1
outputfile=$2
caption=${3:-"phase space"}

[ $# -lt 1 ] && echo "Usage: $0 fileToBeSDDSed" && exit 1

if [ ! -e sddshead ]
then
cat << EOF > sddshead
SDDS1
&description text="$3", contents="output phase space", &end
&column name=t,  symbol=t,  units=s, description="time", format_string=%.14e, type=double,  &end
&column name=p,  symbol=p,  units="m\$be\$nc", description="momentum", format_string="%.14e", type=double,  &end
&column name=x,  symbol=x,  units=m, description="horizontal position", format_string=%.14e, type=double,  &end
&column name=y,  symbol=y,  units=m, description="vertical position",   format_string=%.14e, type=double,  &end
&column name=xp, symbol=x', description="horizontal slop", format_string=%.14e, type=double,  &end
&column name=yp, symbol=y', description="vertical slop",   format_string=%.14e, type=double,  &end
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
