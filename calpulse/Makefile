EXEC     = calpulse
GETDPATH = ../Getdp
OBJECTS  = calpulse.o $(GETDPATH)/getdp_fun.o
CC       = g++
CXXFLAGS = -O2 -Wall -Wconversion -s -I$(GETDPATH)
#-m32
#-static

all: $(EXEC)
calpulse: $(OBJECTS)
	$(CC) $(CXXFLAGS) -o $@ $(OBJECTS)

calpulse.o: $(GETDPATH)/getdp_fun.h
getdp_fun.o: $(GETDPATH)/getdp_fun.h

.PHONY: all clean
clean:
	-rm $(OBJECTS) 2> /dev/null
