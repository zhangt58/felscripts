#### felsim

General FEL simulation approach:
* Beam dynamics is handled by `elegant`;
* FEL generation is handled by `genesis 1.3`;
* Data interfacing is handeld by third-party programs/scripts.

see example in [EEHG10](EEHG10) folder.

All scripts/programs:
```shell
scripts/
├── addSDDShead_elg.sh
├── addSDDShead_gen.sh
├── beta_SASE.sh
├── beta_scriptSASE.m
├── calB1.sh
├── calB2.sh
├── calemit_csr.m
├── calemit.m
├── EEHGres.m
├── FELspectra.m
├── file2sliceD
├── genesis
├── genplot.sh
├── getpal.sh
├── match.sh
├── modu
├── move.sh
├── out2dist.sh
├── plotfiles.sh
├── preMatch.m
├── preMatch.sh
├── readdpa
├── readdpa_tdp.m
├── reform.sh
├── runEEHG.sh
├── runFELs_csr.sh
├── runFELs.sh
├── runFELs_test.sh
├── scanlat.sh
├── setParams.sh
├── showModAmp.m
├── showtrajx.m
├── src
│   ├── element.cpp
│   ├── element.h
│   ├── element.o
│   ├── filestreams.cpp
│   ├── filestreams.h
│   ├── interaction.cpp
│   ├── interaction.h
│   ├── interaction.o
│   ├── main.cpp
│   ├── main.o
│   ├── Makefile
│   ├── modu
│   ├── modu.exe
│   ├── modulation.tar.bz2
│   ├── namelist.example
│   ├── readinput.cpp
│   ├── readinput.h
│   └── readinput.o
├── testsign.sh
└── transdpa.m
```
