## felscripts

Data post-processing and optimization scripts/programms for free-electron laser simulating code (Genesis 1.3) written in C/C++, Octave (Matlab) and Python.

upload to bitbucket on Jan. 24th, 2014.

migrate to github on May. 22nd, 2015.

#### contents:
* [Getdp](/Getdp): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg)
, Extract data block from time-dependent output files, according to the slice order or z order, regarding to options. 
* [PhaseShift](/PhaseShift): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg)
, Simulating phase shift between electron bunch and radiation field.
* [Readdpa](/Readdpa): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg)
, extract data from .dpa files
* [calpulse](/calpulse): ![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg), calculate pulse energy and average pulse power, utilizing <code>getdp_s</code> and <code>getdp_z</code>
* [optimizatoinSuite](/optimizationSuite): 
