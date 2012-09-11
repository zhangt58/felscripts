readdpa_tdp: readdpa_tdp.o methods.o
	g++ -o readdpa_tdp readdpa_tdp.o methods.o -O2 -s
readdpa_tdp.o: readdpa_tdp.cpp methods.h
	g++ -c readdpa_tdp.cpp
methods.o: methods.cpp methods.h
	g++ -c methods.cpp
.PHONY: clean
clean:
	-rm *.o
