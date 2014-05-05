#!/bin/bash

[ $# -lt 1 ] && echo "Usage: $0 fileToBeCopyrighted" && exit 1

while [ $# -ge 1 ]
do
	filetocp=$1
	shift
	sed "\$r ${filetocp}" COPYRIGHT > tmp.$$
	mv tmp.$$ ${filetocp}
done
