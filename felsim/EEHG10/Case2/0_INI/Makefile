.PHONY: run convert all asc2sdds plota combine gen2elg
all: clean run convert combine gen2elg asc2sdds
clean:
	@-rm 0.out* 2> /dev/null
run:
	@-echo 0.in | genesis > /dev/null
convert:
	@../scripts/readdpa_tdp.m 0.out.dpa slice 20000 asc 0
combine:
	@-cat slice{1..500} > 0.out.gen
	@-rm slice{1..500}
gen2elg:
	@../scripts/transdpa.m 0.out.gen 0.out.elg 20000 523.5e-9
asc2sdds:
	@#../scripts/addSDDShead_gen.sh 0.out.gen 0.out.gen.sdds "genesis"
	@../scripts/addSDDShead_elg.sh 0.out.elg 0.out.elg.sdds "elegant"
plot:
	@#-sddsplot 0.out.gen.sdds -col=theta,gamma -graph=dot
	@-sddsplot 0.out.elg.sdds -col=t,p -graph=dot
