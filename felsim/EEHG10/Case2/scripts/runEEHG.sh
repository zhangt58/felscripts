#!/bin/bash

pwdir=$(pwd)

logfile=${pwdir}/../LOG/logs

cd ${pwdir}/../0_INI/
make all >  ${logfile}
echo "1 0.out.asc done" 

cd ${pwdir}/../MOD/mod1/
make all >> ${logfile}
echo "2 mod1.modu done"

cd ${pwdir}/../DS/ds1/
make all >> ${logfile}
echo "3 ds1.dist done"

cd ${pwdir}/../MOD/mod2/
make all >> ${logfile}
echo "4 mod2.modu done"

cd ${pwdir}/../DS/ds2/
make all >> ${logfile}
echo "5 ds2.dist done"

