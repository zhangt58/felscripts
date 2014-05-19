CC = g++
OPTIONS = -O2 -Wall -Wconversion -s
#-m32
#-static
ALLEXEC = getdp_s getdp_z
OBJECTS1 = getdp_s.o getdp_fun.o
OBJECTS2 = getdp_z.o getdp_fun.o

all: $(ALLEXEC)
getdp_s: $(OBJECTS1)
	$(CC) $(OPTIONS) -o getdp_s $(OBJECTS1)
getdp_z: $(OBJECTS2)
	$(CC) $(OPTIONS) -o getdp_z $(OBJECTS2)

getdp_s.o: getdp_fun.h
getdp_z.o: getdp_fun.h
getdp_fun.o: getdp_fun.h

#getdp_s: getdp_s.cpp
#	$(CC) $(OPTIONS) -o $@ $<

#getdp_z: getdp_z.cpp
#	$(CC) $(OPTIONS) -o $@ $<

.PHONY: all clean
clean:
	-rm $(ALLEXEC) $(OBJECTS1) $(OBJECTS2) 2> /dev/null
