.PHONY: clean run plot convert all r56
all: run convert move
run:
	@elegant chi1_CSR.ele
plot:
	@sddsplot ds1.out -col=t,p -graph=dot
convert:
	@../../../scripts/out2dist.sh ds1.out
clean:
	@-rm *.csr *.cen *.fin *.mat *.mpr *.sig *.twi *.out *.dist
r56:
	@sddsprintout chi1_CSR.mat ds1.r56 -col=R56
	@./calB1.sh
move:
	@bash move.sh ds1.dist
