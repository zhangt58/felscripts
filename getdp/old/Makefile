CC = g++
CXXFLAGS = -O2 -Wall -Wconversion -s -static
#-m32
EXEC = getdp_z getdp_s

all: $(EXEC)

getdp_s: getdp_s.cpp
	$(CC) $< $(CXXFLAGS) -o $@

getdp_z: getdp_z.cpp
	$(CC) $< $(CXXFLAGS) -o $@

.PHONY: all clean
clean:
	-rm $(EXEC) 2> /dev/null
