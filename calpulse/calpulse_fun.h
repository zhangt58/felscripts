#ifndef _CALPULSE_H
#define _CALPULSE_H

#include <string>

// calculate radiation pulse energy gain curve
double calpegc(std::string &infilename, std::string &outfilename, std::string &unit, int intstep);

// calculate radiation pulse energy at z-position
double calpesp(std::string &infilename, std::string &unit, int zrecord);

#end // _CALPULSE_H
