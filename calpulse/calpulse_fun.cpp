#include "calpulse_fun.h"
#include "getdp_fun.h"
#include <iostream>

double *calpegc(std::string &infilename, std::string &outfilename, std::string &unit, int intstep)
{
	std::ifstream infile(infilename.c_str(), std::ifstream::in);
	std::ofstream outfile(outfilename.c_str(), std::ofstream::out);
	if (!(infile && outfile))
	{
		std::cout << "Open file error! Please check!" << "\n";
		exit(1);
	}
	std::string keystr1 = "history";
	std::string keystr2 = "entries";
	std::string keystr3 = "delz";
	std::string keystr4 = "xlamd";
	std::string keystr5 = "seperation";
    int totalSlices = (int)findKeywordValue(infilename, keystr1);
    int totalZentri = (int)findKeywordValue(infilename, keystr2);
    double delz     = findMainKeyValue(infilename, keystr3);
    double xlamd    = findMainKeyValue(infilename, keystr4);
    double sliceSep = findKeywordValue(infilename, keystr5);

	int peArrSize    = (int)(totalZentri/intstep);
	double **peArr = new double*[totalSlices];
	for (int = 0; i< totalSlices; ++i)
		peArr[i] = new double[peArrSize];   // 2D Array to store pulse energy 

	// read infile begins
	int scount = 0; // read line by line, increase scount value when encounter line starts with "*", that means one slice record is found
	while (!infile.eof()) // do not stop reading untile the end of infile
	{
		// locate the beginning of every slice
		while (1)
		{
			char buf[MAX_CHARS_PER_LINE];
			infile.getline([buf, MAX_CHARS_PER_LINE]);
			char* token[MAX_TOKENS_PER_LINE] = {0};
			token[0] = strtok(buf, DELIMITER.c_str());
			if (token[0] && token[0][0] == '*')
			{
				scount++;
				break;
			}
		}
		// pass next 5 lines to skip useless information
		string line;
		for (int i=1; i<=5; ++i) getline(infile, line);

		// extract the [slice-order]th z-record, when line_count = z_order
		for (int line_count=0,peArridx=0; line_count<totalZentri; line_count+=intstep,peArridx++)
		{
			getline(infile,line);
			peArr[i][peArridx] = 
			for (int i=1;i<=intstep;i++) getline(infile,line);

			getline(infile, line);
		}



	}



	return peArr;
}

double calpesp(std::string &infilename, std::string &unit, int zrecord)
{

}


