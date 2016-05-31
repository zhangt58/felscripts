CC = g++
OPTIONS = -O2 -Wall -Wconversion 
#-static
OBJECTSD = file2sliceD.o splitfile.o
EXEC = file2sliceD

$(EXEC): $(OBJECTSD)
	$(CC) $(OPTIONS) -o $@ $^

file2sliceD.o: splitfile.h
	$(CC) -c $(OPTIONS) file2sliceD.cpp -o $@
splitfile.o: splitfile.h
	$(CC) -c  $(OPTIONS) splitfile.cpp -o $@

.PHONY: clean install pack rebuild
clean:
	-rm -rf $(OBJECTSD) $(EXEC)
install:
	-cp $(EXEC) ../../../scripts/
pack:
	-tar cjvf file2sliceD.tar.bz2 *.h *.cpp Makefile README
rebuild: clean $(EXEC) install
