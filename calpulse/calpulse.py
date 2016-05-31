#!/usr/bin/python2
"""
todo:
	argv[2] default 0
	add options, -s slicenum, -z zrecord-num

"""

"""
This script is written for data processing for Genesis output file.

"""

import sys

filename1 = sys.argv[1] # TDP output filename defined by external parameter
#slicetoshow = int(sys.argv[2]) # slice number to show as picture
#zrecordtoshow = int(sys.argv[2])# z-record num
filename2 = sys.argv[2] # file to dump [pulse energy] v.z. [z]
showit    = sys.argv[3] # if plot figure

#open files
f1 = open(filename1, 'r')

#extract z, au, QF [BEGIN]
while not f1.readline().strip().startswith('z[m]'):pass
zaq   = []
line  = f1.readline().strip()
count = 0
while line:
    zaq.append(line)
    line = f1.readline().strip()
    count += 1
#print "%d lines have been read!" %count
#count: total z-record number
#extraxt z, au, QF [END]


#find where to extract power ...
slicenum = 0 # count read slice num
data=[]
while True:
    while not f1.readline().strip().startswith('power'):pass
    data.append([])
    slicenum += 1
    line = f1.readline().strip()
    while line: 
#        data[slicenum-1].append(["%2.6E" %float(x) for x in line])
        data[slicenum-1].append(line)
        line = f1.readline().strip()
#    print 'Read slice %05d' %slicenum
    if not f1.readline():break

f1.close()
#data extraction end, close opened file

#print sys.getsizeof(zaq)
#raw_input()

cmd1 = "/bin/grep -m1 sepe " + filename1 + " | awk '{print $1}'"
cmd2 = "/bin/grep xlamd "    + filename1 + " | /bin/grep -v xlamds | awk -F'=' '{print $NF}' | sed 's/[D,d]/e/g'"
cmd3 = "/bin/grep delz "     + filename1 + " | awk -F'=' '{print $NF}' | sed 's/[D,d]/e/g'"

#import subprocess
#if hasattr(subprocess,'check_output'):
#    dels  = float(subprocess.check_output(cmd1, shell = True))
#    xlamd = float(subprocess.check_output(cmd2, shell = True))
#    delz  = float(subprocess.check_output(cmd3, shell = True))*xlamd
#else:
#    import os
#    dels  = float(os.popen4(cmd1)[1].read())
#    xlamd = float(os.popen4(cmd2)[1].read())
#    delz  = float(os.popen4(cmd3)[1].read())*xlamd

try:
    import subprocess
    dels  = float(subprocess.check_output(cmd1, shell = True))
    xlamd = float(subprocess.check_output(cmd2, shell = True))
    delz  = float(subprocess.check_output(cmd3, shell = True))*xlamd
except AttributeError:
    import os
    dels  = float(os.popen4(cmd1)[1].read())
    xlamd = float(os.popen4(cmd2)[1].read())
    delz  = float(os.popen4(cmd3)[1].read())*xlamd

c0 = 299792458.0

import numpy as np
x  =  np.arange(count)
s  =  np.arange(slicenum)
z  =  np.array([float(zaq[i].split()[0]) for i in x])
#p1 =  [data[slicetoshow][i].split()[0] for i in x]
##ps =  [data[i][zrecordtoshow].split()[0] for i in s]
##plot(s,ps,'r-')
##plot(z,p1,'r-')

j=0
pe=[]
pmax = 0
idx = int(sys.argv[4])
"""
idx = 0  # fundamental power
idx = 15 # 3rd harmonic power
idx = 23 # 5th harmonic power
"""
while j < count:
	psi =  [data[i][j].split()[idx] for i in s]
	ptmp = max([float(x) for x in psi])
	if ptmp > pmax:
		pmax = ptmp
	pe.append(sum([float(x) for x in psi])*dels/c0)
	j +=1
maxpe = max(pe)
psmax = [data[i][pe.index(maxpe)].split()[0] for i in s]
print "Pulse Energy: ", maxpe*1e9, "nJ @ z= ", pe.index(maxpe)*delz
print "Max Power: ",pmax, "W" 

# write z,pe data into filename2
np.savetxt(filename2, np.vstack((z,1e6*np.array(pe))).T, fmt='%.6e', delimiter=' ')

if showit == '1':
	import pylab as plt
	plt.subplot(2,1,1)
	plt.plot(z,np.array(pe)*1e9,'b-')
	plt.hold(True)
	plt.plot(pe.index(maxpe)*delz,maxpe*1e9,'ro')
	plt.ylim([0,1.1*maxpe*1e9])
	plt.grid(True)
	plt.xlabel('z [m]')
	plt.ylabel('Pulse Energy [nJ]')

	plt.subplot(2,1,2)
	plt.plot(s*dels*1e6,np.array(psmax),'r-')
	plt.xlabel('s [$\mu$m]')
	plt.ylabel('Power [W]')
	plt.grid(True)

	plt.show()
