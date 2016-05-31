CC = g++
OPTIONS = -O2 -Wall -Wconversion
#-static 
OBJECTS = main.o readinput.o element.o interaction.o

modu: $(OBJECTS) 
	$(CC) $(OPTIONS) -o $@ $^
main.o: readinput.h element.h interaction.h
	$(CC) -c $(OPTIONS) main.cpp -o $@
readinput.o: readinput.h
	$(CC) -c $(OPTIONS) readinput.cpp -o $@
element.o: element.h
	$(CC) -c $(OPTIONS) element.cpp -o $@
interaction.o: interaction.h element.h
	$(CC) -c $(OPTIONS) interaction.cpp -o $@

.PHONY: clean pack install rebuild
clean:
	-rm -rf $(OBJECTS)
pack:
	-tar cjvf modu.tar.bz2 *.cpp *.h namelist.example Makefile
install:
	-cp modu ../../scripts/
rebuild: clean modu install
