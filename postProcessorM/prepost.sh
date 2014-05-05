#!/bin/bash

outfile=$1

npart=$(grep -n npart ${outfile} | awk '{print $NF}')


