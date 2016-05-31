## felscripts

Data post-processing and optimization scripts/programms for free-electron laser simulating code (Genesis 1.3) written in C/C++, Octave (Matlab) and Python.

#####Log:
* 2014-01-24: upload to bitbucket
* 2015-05-22: migrate to github 
* 2016-05-31: add more READMEs and scripts/programs

#### contents:
* [getdp](/getdp): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg), 
Extract data block from time-dependent output files, according to the slice order or z order, regarding to options. 
* [phaseshifter](/phaseshifter): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg),
Simulating phase shift between electron bunch and radiation field.
* [readdpa](/readdpa): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg), 
Extract data from .dpa files.
* [calpulse](/calpulse): ![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg), ![python](https://img.shields.io/badge/python-2.7-brightgreen.svg), 
Calculate pulse energy and average pulse power, utilizing <code>getdp_s</code> and <code>getdp_z</code> (shell version) and more efficient Python version (calpulse.py).
* [optimizationSuite](/optimizationSuite): ![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg), 
Parameters optimization scripts.
* [postProcessorM](/postProcessorM): [!octave](https://img.shields.io/badge/matlab-octave-brightgreen.svg),
Octave/matlab scripts for handle dpa and dfl binary files.
* [readdpa_tdp](/readdpa_tdp): ![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg),
Read .dpa files and provide additional information.
* [readfld_tdp](/readfld_tdp): [!octave](https://img.shields.io/badge/matlab-octave-brightgreen.svg),
Read .dfl binary file, to calculate the projected angular distribution.
* [seed_gen](/seed_gen): [!octave](https://img.shields.io/badge/matlab-octave-brightgreen.svg), ![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg),
Generate seed laser file for genesis 1.3 (radfile).
* [spectralAnalysis](/spectralAnalysis): [!octave](https://img.shields.io/badge/matlab-octave-brightgreen.svg), ![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg),
Calculate spectral data file from TDP output file.
* [beta match](/beta_match): [!octave](https://img.shields.io/badge/matlab-octave-brightgreen.svg), ![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg),
Twiss parameters matching for SASE, HGHG, EEHG, etc.




