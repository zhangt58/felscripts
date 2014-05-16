#ifndef _GETDP_FUN_H
#define _GETDP_FUN_H

#include <ifstream>
#include <string>
#include <cstdlib>

// const list
const int MAX_CHARS_PER_LINE  = 512;
const int MAX_TOKENS_PER_LINE = 20; 
const char* DELIMITER = " \t";

double findKeywordValue(std::ifstream &infile, std::string &keystr);
// keystr list:
// entries
// history
// wavelength
// seperation
// meshsize

#endif //_GETDP_FUN_H
