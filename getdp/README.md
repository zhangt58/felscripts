####Package Overview:

<code>getdp</code> : Extract data block by _slice-order_ or _z-entry order_ from GENESIS 1.3 TDP simulation output files.

old versions (in [old](/old) folder): <code>getdp_s</code> and <code>getdp_z</code> served as extracting slice or entry records.

The usage can be found by simply type <code>getdp</code> or <code>getdp --help</code> in terminal.

e.g.
`getdp`

```shell
Usage: ../getdp [--flag value]...

Usage Example (1): ../getdp --input infilename --output outfilename --s 1 --sOrder 100
Usage Example (2): ../getdp --input infilename --output outfilename --z 1 --zOrder 100
Usage Example (3): ../getdp --help
Usage Example (4): ../getdp --input infilename --showRange 1

Mandatory Options:
	--input infile
		TDP output file
	--output outfile
		File for data dumping

	Third mandatory flag: --s or --z
		--s sFlag
			Data extraction type: slice
			default value: 0, enable by set 1
			Meanwhile --sOrder or --sPos should be set
	Or:
		--z zFlag
			Data extraction type: zentry
			default value: 0, enable by set 1
			Meanwhile --zOrder or --zPos should be set

Other Options:
	--sOrder isOrder
		Extract slice order
	--zOrder izOrder
		Extract z-entry order
	--sPos dsPos
		Extract slice position in [m]
		if --sOrder and --sPos are all
		defined, --sOrder is used by ../getdp
	--zPos dzPos
		Extract zentry position in [m]
		if --zOrder and --zPos are all
		defined, --zOrder is used by ../getdp
	--showRange ishowRange
		Flag for showing record range, default 0,
		should be used by given --input infilename
```

`old/getdp_z test/template.out zoutput1 10` and `getdp_z --input test/template.out --output zoutput2 --z 1 --zOrder 10` will give the same output, i.e. `zoutput1` and `zoutput2` are identical.

The same rule applies to `getdp_s` new and old version.

