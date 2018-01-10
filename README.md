## felscripts
![C/C++](https://img.shields.io/badge/C-C%2B%2B-brightgreen.svg)
![bash](https://img.shields.io/badge/shell-bash-brightgreen.svg)
![python](https://img.shields.io/badge/python-2.7-brightgreen.svg)
![octave](https://img.shields.io/badge/matlab-octave-brightgreen.svg)

Data post-processing and optimization scripts/programms for free-electron laser simulating code (Genesis 1.3) written in kinds of languages.

#### contents:
* [getdp](/getdp): C/C++, extract data block from time-dependent output files, according to the slice order or z order, regarding to options.
* [phaseshift](/phaseshift): C/C++, simulating phase shift between electron bunch and radiation field.
* [readdpa](/readdpa): C/C++, extract data from .dpa files.
* [calpulse](/calpulse): Bash Shell/Python, calculate pulse energy and average pulse power, utilizing <code>getdp_s</code> and <code>getdp_z</code> (shell version) and more efficient Python version (calpulse.py).
* [optimizationSuite](/optimizationSuite): Bash Shell, parameters optimization scripts.
* [postProcessorM](/postProcessorM): Octave/Matlab, scripts for handle dpa and dfl binary files.
* [readdpa_tdp](/readdpa_tdp): C/C++, read .dpa files and provide additional information.
* [readfld_tdp](/readfld_tdp): Octave/Matlab, read .dfl binary file, to calculate the projected angular distribution.
* [seed_gen](/seed_gen): Bash Shell/Octave/Matlab, generate seed laser file for genesis 1.3 (radfile).
* [spectralAnalysis](/spectralAnalysis): Bash Shell/Octave/Matlab, calculate spectral data file from TDP output file.
* [beta match](/beta_match): Bash Shell/Octave/Matlab, twiss parameters matching for SASE, HGHG, EEHG, etc.
* [felsim](/felsim): Bash Shell/Octave/Matlab/C/C++, general FEL simulation approach.

#### Log:
* 2014-01-24: upload to bitbucket
* 2015-05-22: migrate to github
* 2016-05-31: add more READMEs and scripts/programs
