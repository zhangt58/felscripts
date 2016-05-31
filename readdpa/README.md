#### readdpa

Read .dpa binary files (6D electron particle phase space distributions) dumped from GENESIS 1.3 and generate the required beam distribution for further simulations.

Subprogram list:

* <code>readdpa</code>: read .dpa file from GENESIS, generate required beam distribution for further simulations
* <code>readdpa_lite</code>: lite version of <code>readdpa</code>

Usage:
```shell
Usage: ./readdpa dpafile ascfile multitimes format

 This program will generate multitimes dpafile to ascfile.
 e.g. if dpafile contain [0,2pi], then ascfile will range from [0,2pi*N].

 3rd param: data format, elegant or genesis

 Column-name conventions:
  elegant format:|--t--|gamma|--x--|--y--|betax|betay|
  genesis format:|gamma|theta|--x--|--y--|--xp-|--yp-|
  where xp=gamma*betax, yp=gamma*betay, respectively.
```
