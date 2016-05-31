CC = g++
CXXFLAGS = -O2 -Wall -Wconversion -s -static
#-m32
EXEC = getdp
OBJECTS = getdp.o getdp_fun.o

all: $(EXEC)
getdp: $(OBJECTS)
	$(CC) $(CXXFLAGS) -o $@ $(OBJECTS)

getdp.o: getdp_fun.h
getdp_fun.o: getdp_fun.h

.PHONY: all clean
clean:
	-rm $(OBJECTS) 2> /dev/null
