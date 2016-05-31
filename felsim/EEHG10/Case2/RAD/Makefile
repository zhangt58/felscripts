.PHONY: split clean plot ascsplit
split:
	@[ ! -e ./mslices ] && mkdir ./mslices; cd ./mslices; ../../scripts/file2sliceD --input ../../DS/ds2/newds2.dist --npart 10000000 --xlamds 230.32e-9 --outformat bin
splitcsr:
	@[ ! -e ./csrslices ] && mkdir ./csrslices; cd ./csrslices; ../../scripts/file2sliceD --input ../../DS/ds2/CSR/newds2.dist --npart 10000000 --xlamds 230.32e-9 --outformat bin
ascsplit:
	@[ ! -e ./ascSlices ] && mkdir ./ascSlices; cd ./ascSlices; ../../scripts/file2sliceD --input ../../DS/ds2/ds2.dist --npart 58566 --xlamds 230.3e-9 --outformat asc
plot:
	@[ -e ./ascSlices ] && cd ./ascSlices/; \
		../../scripts/plotfiles.sh 1 `ls slice* | wc -l` 1 slice; \
		cat pltslices.plt | gnuplot --persist
clean:
	@-rm -rf ./slices ./ascSlices
