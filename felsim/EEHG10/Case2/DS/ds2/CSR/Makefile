.PHONY: clean run plot convert all r56
all: run convert
run:
	@elegant chi2_CSR.ele 
plot:
	@sddsplot ds2.out -col=t,p -graph=dot
convert:
	@../../../scripts/out2dist.sh ds2.out
clean:
	@-rm *.csr *.cen *.fin *.mat *.mpr *.sig *.twi *.out *.dist
r56:
	@sddsprintout chi2_CSR.mat ds2.r56 -col=R56
	@./calB2.sh
