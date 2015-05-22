CC = g++
OPTIONS = -O2 -Wall -Wconversion -s
#-m32
#-static
ALLEXEC = phaseshift manibeam

all: $(ALLEXEC)

phaseshift: phaseshift.cpp
	$(CC) $(OPTIONS) -o $@ $<
manibeam: manibeam.cpp
	$(CC) $(OPTIONS) -o $@ $<

.PHONY: all clean
clean:
	-rm $(ALLEXEC) 2> /dev/null
