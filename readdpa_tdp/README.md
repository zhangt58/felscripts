#### readdpa_tdp

Refactored dpa reader and manipulator by C++.

additional information provides:
* peak current
* bunching factor at nth harmonic

Usage:
```shell
Usage: ./readdpa_tdp file1 file2 total_slice total_charge xlamds zsep nharm
	file1: 		dpa file to be read
	file2: 		current file
	total_slice: 	total slice number of dpa file
	total_charge: 	total bunch charge in [pC]
	xlamds: 	wavelength [nm]
	zsep  : 	slice spacing in xlamds
	nharm : 	for bunching factor calculation
```
