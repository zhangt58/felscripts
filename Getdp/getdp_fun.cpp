#include "getdp_fun.h"
#include <iostream>

double findKeywordValue(std::string &filename, std::string &keystr)
{
	std::ifstream infile;
	infile.open(filename.c_str(), std::ifstream::in);
	if(!infile)
	{
		std::cout << filename << " can not open!" << std::endl;
		exit(1);
	}
    char buf[MAX_CHARS_PER_LINE];
    char* tokenTmp1;
    char* tokenTmp2;
    while (!infile.eof())
    {
        infile.getline(buf, MAX_CHARS_PER_LINE);
        char* token = strtok(buf, DELIMITER.c_str());
        if (token)
        {
			tokenTmp1 = token;
			if((tokenTmp2 = strtok(NULL, DELIMITER.c_str())) && !strcmp(tokenTmp2, keystr.c_str())) break;
		}
	}
	infile.close();
	return atof(tokenTmp1);
}

double findMainKeyValue(std::string &filename, std::string &keystr)
{
	std::ifstream infile;
	infile.open(filename.c_str(), std::ifstream::in);
	if(!infile)
	{
		std::cout << filename << " can not open!" << std::endl;
		exit(1);
	}
	char buf[MAX_CHARS_PER_LINE];
	char* tokenTmp1;
	char* tokenTmp2;
	while (!infile.eof())
	{
		infile.getline(buf, MAX_CHARS_PER_LINE);
		char* token = strtok(buf, DELIMITER.c_str());
		if (token)
		{
			tokenTmp1 = token;
			if(!strcmp(tokenTmp1, keystr.c_str()) && (tokenTmp2 = strtok(NULL, DELIMITER.c_str()))) break;
		}
	}
	infile.close();
	return atof(dToE(std::string(tokenTmp2)).c_str());
}

std::string dToE(std::string cppstr)
{
	cppstr.replace(cppstr.find("D"),1,"E");
	return cppstr;
}

