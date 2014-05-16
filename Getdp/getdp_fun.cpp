#include "getdp_fun.h"

double findKeywordValue(ifstream &infile, string &keystr)
{
    char buf[MAX_CHARS_PER_LINE];
    char* tokenTmp1;
    char* tokenTmp2;
    while (!infile.eof())
    {
        infile.getline(buf, MAX_CHARS_PER_LINE);
        char* token = strtok(buf, DELIMITER);
        if (token)
        {
			tokenTmp1 = token;
			if((tokenTmp2 = strtok(NULL, DELIMITER)) && !strcmp(tokenTmp2, keystr.c_str()))
			{
				cout << tokenTmp1 << endl;
				break;
			}
		}
	}
	infile.close();
	return atof(tokenTmp1);
}

