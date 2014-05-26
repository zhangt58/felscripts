#ifndef _GETDP_FUN_H
#define _GETDP_FUN_H

#include <fstream>
#include <string>
#include <cstdlib>
#include <cstring>

// const list
const int MAX_CHARS_PER_LINE  = 512;
const int MAX_TOKENS_PER_LINE = 20; 
const std::string DELIMITER = " \t=";

double findKeywordValue(std::string &filename, std::string &keystr);
// keystr list:
// entries
// history
// wavelength
// seperation
// meshsize

double findMainKeyValue(std::string &filename, std::string &keystr);
// keystr list:
// delz
// xlamd
// etc.

// convert scientific notation with D into E, e.g. 1.0D+01 to be 1.0E+01
std::string dToE(std::string cppstr); 

// parse input options
int parseOpts(int argc, char* argv[], 
		      std::string &infilename, std::string &outfilename,
			  int &isOrder, double &dsPosition,
			  int &izOrder, double &dzPosition,
			  int &sFlag, int &zFlag,
			  int &ishowRange);

// check input options
void checkParams(int argc, char* argv[]);

// show s/z order range, min to max
void showRange(std::string &infilename);

#endif //_GETDP_FUN_H
