.PHONY: run convert plot all clean
all: run convert
run:
	@../../scripts/modu namelist1 >/dev/null
convert:
	@../../scripts/addSDDShead_elg.sh mod1c.modu mod1c.sdds "AfterM1 (C)"
	@../../scripts/addSDDShead_elg.sh mod1.modu  mod1.sdds  "AfterM1 (M)"
plot:
	@-sddsplot mod1c.sdds -col=t,p -graph=dot
	@#-sddsplot mod1.sdds  -col=t,p -graph=dot
clean:
	@-rm mod1c.modu mod1c.sdds mod1.modu mod1.sdds
