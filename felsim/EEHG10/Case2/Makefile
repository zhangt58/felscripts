#===========================================================================
# Makefile for running EEHG simulation
# Author: Tong ZHANG (tzhang@sinap.ac.cn)
# Created: Jan. 24th, 2013
# Revised: Jan. 29th, 2013
# --------------------------------------------------------------------------

subdirs = 0_INI MOD/mod1 DS/ds1 MOD/mod2 DS/ds2
srcdirs = MOD/src RAD/src/file2slice RAD/src/genesis_080416

.PHONY: EEHG plot clean r56 setup gen0 mod1 ds1 mod2 ds2 rad buildsrc
EEHG: buildsrc setup gen0 mod1 ds1 mod2 ds2 rad
MODS: setup gen0 mod1 ds1 mod2 ds2
setup:
	@cd ./scripts; ./setParams.sh 20000 500 523.5e-9
gen0:
	@cd 0_INI; make all
mod1:
	@cd MOD/mod1; make all
ds1:
	@cd DS/ds1; make all
mod2:
	@cd MOD/mod2; make all
ds2:
	@cd DS/ds2; make all
rad:
	@cd RAD; make clean split; ./runFELs.sh
plot:
	@for dir in $(subdirs); do (cd $$dir; make plot); done
clean:
	@for dir in $(subdirs); do (cd $$dir; make clean); done
	@cd RAD; make clean
r56:
	@for dir in {"DS/ds1","DS/ds2"}; do (cd $$dir; make r56); done
buildsrc:
	@for dir in $(srcdirs); do (cd $$dir; make rebuild); done
