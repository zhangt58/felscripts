###Package name: `optTaper`
###Belongs to package: `optimizationSuite`
####Information:
Author: Tong Zhang

E-mail: zhangtong@sinap.ac.cn

Time  : 2014-05-12, 19:24 CST 

####Overview:
Optimize undulator tapering set up for an free-electron laser. 
The script `optTaper_p.sh` is designed for parameters setup. 
Two parameters: taper begins z-pos and total tapered percent are 
chosen as the optimization parameters, this script is designed 
to distribute the optimization work to multithreaded workers, 
by default all CPU cores would be called.

Script `optTaper.sh` is the main functional procedure for 
FEL optimization, the input parameters would be transferred from
the main script `optTaper_p.sh`, all the workers would start
to work.

When all the workers finished the job, main script `optTaper_p.sh`
would collect all the results data and merge into single file as the
final result. Further the optimized taper setup would be figured out
and substitute the value in the input file.
