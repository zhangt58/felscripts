###Package name: _optAW_
###Belongs to package: _optimizationSuite_
####Information:
> Author: Tong Zhang

> E-mail: zhangtong@sinap.ac.cn

> Time  : 2014-10-30, 09:15 CST 
####Overview:
>	Optimize the undulator parameters (au) for an free-electron laser. 
>   The script <code>optaw_p.sh</code> is designed for parameters setup. au 
>	scanning range including begin value, end value and step values, 
>   all are integers; and factor ratio (also an integer) required to 
>   be divided by the input integers to get the true float values, 
>   these are all shell scripting tricks in dealing with arithmetical 
>   calculation. 
>	Input file name also should be defined in <code>optaw_p.sh</code>.
>	After that, <code>optaw_p.sh</code> would distribute the whole work
>	to multithreaded workers, by default all CPU cores would be called.
>
>	Script <code>optaw.sh</code> is the main functional procedure for 
>	au optimization, the input parameters would be transferred from
>	the main script <code>optaw_p.sh</code>, all the workers would start
>	to work.
>
>	When all the workers finished the job, main script <code>optaw_p.sh</code>
>	would collect all the results data and merge into single file as the
>	final result. Further the optimized aw value would be figured out
>	and substitute the value in the input file/lattice file.
