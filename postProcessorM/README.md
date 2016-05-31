Postprocessing scripts written in m language, could be executed by `octave` and `matlab`.

Scripts including:
* `readdpa_tdp.m`: general-purposed script to handle dpa file, both valid for TDP and steady-state cases;
* `readdpa.m`: handle single slice;
* `readdfl.m`: read field files, i.e.: .dfl binary files;
* `readdfl_show.m`: plot field data;

Show usage:
```shell
Usage: readdpa_tdp.m [option] binfile outfile npart datafmt mflag [slices]
	 binfile: filename of the binary dpa/par file to read
	 outfile: name head of the ascii slice files to write
	 npart  : particle number of the dpa file (per slice)
	 datafmt: data format of the output, bin or asc
	 mflag  : whether 2nd col (mod theta col) moded, 1 or 0
	 slices : range of the slices to be extracted (optional)
	          format min:step:max, 1:1:nslice by default
	 P.S:     slice# of .dpa and zentri# of .par is equivalent

Option:
	--info	Show the meanings of each column of the ascfile
```

```shell
Usage: readdpa.m [option] dpafile outfile npart datafmt [slices]
	 dpafile: filename of the binary dpa file to read
	 outfile: name head of the ascii slice files to write
	 npart  : particle number of the dpa file
	 datafmt: data format of the output, bin or asc
	 slices : range of the slices to be extracted (optional)
	          format min:step:max, 1:1:nslice by default

Option:
	--info	Show the meanings of each column of the ascfile
```
