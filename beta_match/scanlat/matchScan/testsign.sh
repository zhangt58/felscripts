#!/bin/bash
#==========================================================================
#
#          FILE:  testsign.sh
# 
#         USAGE:  ./testsign.sh 
# 
#   DESCRIPTION:  test if FODO is reasonable
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Tong Zhang (), tzhang@sinap.ac.cn
#       COMPANY:  FEL physics Group, SINAP
#       VERSION:  1.0
#       CREATED:  02/17/2011 02:22:25 PM CST
#      REVISION:  ---
#==========================================================================

QF1=$1
QF2=$2
bash beta_HGHG.sh ${QF1} ${QF2}
