CC = g++
OPTIONS = -O2 -Wall -Wconversion -s
#-m32
#-static
EXEC = getdp
OBJECTS = getdp.o getdp_fun.o

all: $(EXEC)
getdp: $(OBJECTS)
	$(CC) $(OPTIONS) -o $@ $(OBJECTS)

getdp.o: getdp_fun.h
getdp_fun.o: getdp_fun.h

.PHONY: all clean
clean:
	-rm $(OBJECTS) 2> /dev/null
