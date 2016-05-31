CC = g++
OPTIONS = -O2 -Wall -Wconversion
#-static -m32
OBJECTS  = readdpa.o
OBJECTSL = readdpa_lite.o

All: readdpa readdpa_lite

readdpa: $(OBJECTS) 
	$(CC) $(OPTIONS) -o readdpa $(OBJECTS)
readdpa_lite: $(OBJECTSL) 
	$(CC) $(OPTIONS) -o readdpa_lite $(OBJECTSL)

readdpa.o: readdpa.cpp
	$(CC) -c $(OPTIONS) readdpa.cpp
readdpa_lite.o: readdpa_lite.cpp
	$(CC) -c $(OPTIONS) readdpa_lite.cpp

.PHONY: clean
clean:
	-rm -rf $(OBJECTS) $(OBJECTSL)
