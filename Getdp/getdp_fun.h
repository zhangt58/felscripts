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

std::string dToE(std::string cppstr);

#endif //_GETDP_FUN_H
