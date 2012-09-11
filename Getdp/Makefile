CC = g++
OPTIONS = -O2 -Wall -Wconversion -s
#-m32
#-static
ALLEXEC = getdp_s getdp_z

all: $(ALLEXEC)

getdp_s: getdp_s.cpp
	$(CC) $(OPTIONS) -o $@ $<

getdp_z: getdp_z.cpp
	$(CC) $(OPTIONS) -o $@ $<

.PHONY: all clean
clean:
	-rm $(ALLEXEC) *.o 2> /dev/null
