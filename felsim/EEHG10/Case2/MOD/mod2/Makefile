.PHONY: run convert plot all clean
all: run convert
run:
	@../../scripts/modu namelist2 > /dev/null
convert:
	@../../scripts/addSDDShead_elg.sh mod2c.modu mod2c.sdds
convertcsr:
	@../../scripts/addSDDShead_elg.sh mod2c_CSR.modu mod2c_CSR.sdds
plot:
	@-sddsplot mod2c.sdds -col=t,p -graph=dot
clean:
	@-rm mod2c.modu mod2c.sdds mod2.modu mod2.sdds
