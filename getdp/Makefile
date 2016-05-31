CC = g++
CXXFLAGS = -O2 -Wall -Wconversion -s -static
#-m32
EXEC = getdp getdp_z getdp_s
OBJECTS = getdp.o getdp_fun.o

all: $(EXEC)
getdp: $(OBJECTS)
	$(CC) $(CXXFLAGS) -o $@ $(OBJECTS)

getdp_s: $(OBJECTS)
	$(CC) $(CXXFLAGS) -o $@ $(OBJECTS)

getdp_z: $(OBJECTS)
	$(CC) $(CXXFLAGS) -o $@ $(OBJECTS)

getdp_z: getdp_z.cpp
getdp_s: getdp_s.cpp
getdp.o: getdp_fun.h
getdp_fun.o: getdp_fun.h

.PHONY: all clean
clean:
	-rm $(OBJECTS) 2> /dev/null
