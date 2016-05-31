#!/bin/bash

distfile=$1
delt=$(head -1 ${distfile} | awk '{print $1}')
awk -v delt=${delt} '{$1-=delt;print;}' ${distfile} > temp.$$
mv temp.$$ ${distfile}
