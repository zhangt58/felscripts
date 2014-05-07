Package name: **optGamma**

Belongs to package: **optimizationSuite**

-----------------------------------------
|Author: | Tong Zhang             |
|E-mail: | warriorlance@gmail.com |
|Time:   | 2014-05-06, 11:40 CST  |
-----------------------------------------

###Overview:
>	Optimize the beam energy for an free-electron laser. The script
>	'*optgamma_p.sh*' is designed for parameters setup. Energy 
>	scanning range in rest energy (gamma = (Energy in MeV)/0.511),
>	including begin value, end value and step values, all are integers;
>	and factor ratio (also an integer) required to be divided by the 
>	input integers to get the true float values, these are all shell
>	scripting tricks in dealing with arithmetical calculation. 
>	Input file name also should be defined in '*optgamma_p.sh*'.
>	After that, '*optgamma_p.sh*' would distribute the whole work
>	to multithreaded workers, by default all CPU cores would be called.
>
>	Script '*optgamma.sh*' is the main functional procedure for 
>	gamma optimization, the input parameters would be transferred from
>	the main script '*optgamma_p.sh*', all the workers would start
>	to work.
>
>	When all the workers finished the job, main script '*optgamma_p.sh*'
>	would collect all the results data and merge into single file as the
>	final result. Further the optimized gamma value would be figured out
>	and substitute the value in the input file.
