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

int parseOpts(int argc, char* argv[], 
		      std::string &infilename, std::string &outfilename,
			  int &isOrder, double &dsPosition,
			  int &izOrder, double &dzPosition,
			  int &sFlag, int &zFlag)
{
	for (int i=1; i < argc-1; i+=2)
	{
		if (argv[i] == std::string("--input"))
			infilename = argv[i+1];
		else if (argv[i] == std::string("--output"))
			outfilename = argv[i+1];
		else if (argv[i] == std::string("--sOrder"))
			isOrder = atoi(argv[i+1]);
		else if (argv[i] == std::string("--zOrder"))
			izOrder = atoi(argv[i+1]);
		else if (argv[i] == std::string("--sPos"))
			dsPosition = atof(argv[i+1]);
		else if (argv[i] == std::string("--zPos"))
			dzPosition = atof(argv[i+1]);
		else if (argv[i] == std::string("--s"))
			sFlag = atoi(argv[i+1]);
		else if (argv[i] == std::string("--z"))
			zFlag = atoi(argv[i+1]);
		else
			return 0; // unknown options
	}
	return 1; // parsing success, return
}

void checkParams(int argc, char* argv[])
{
	if (argc == 1 || (argc > 1 && (argv[1] == std::string("--help") || argv[1] == std::string("-h"))))
	{
		std::cout << "Usage: "<< argv[0] << " [--flag value]..." << "\n";

		std::cout << "\n";
		
		std::cout << "Mandatory Options:" << "\n";
		std::cout << "\t"   << "--input"  << " infile" 	<< "\n";
		std::cout << "\t\t" << "TDP output file" 		<< "\n";
		std::cout << "\t" 	<< "--output" << " outfile" << "\n";
		std::cout << "\t\t" << "File for data dumping"  << "\n";
		
		std::cout << "\n";
		
		std::cout << "\t"     << "Third mandatory flag: --s or --z" << "\n"; 
		std::cout << "\t\t"   << "--s" 	  << " sFlag" 	<< "\n";
		std::cout << "\t\t\t" << "Data extraction type: slice" 	      << "\n";
		std::cout << "\t\t\t" << "default value: 0, enable by set 1" << "\n";
		std::cout << "\t\t\t" << "Meanwhile --sOrder or --sPos should be set" << "\n";
		std::cout << "\t"     << "Or:" << "\n";
		std::cout << "\t\t"   << "--z" 	  << " zFlag" 	<< "\n";
		std::cout << "\t\t\t" << "Data extraction type: zentry" 	  << "\n";
		std::cout << "\t\t\t" << "default value: 0, enable by set 1" << "\n";
		std::cout << "\t\t\t" << "Meanwhile --zOrder or --zPos should be set" << "\n";

		std::cout << "\n";

		std::cout << "Other Options:" << "\n";
		std::cout << "\t" 	<< "--sOrder" << " isOrder" << "\n";
		std::cout << "\t\t" << "Extract slice order"  	<< "\n";
		std::cout << "\t" 	<< "--zOrder" << " izOrder" << "\n";
		std::cout << "\t\t" << "Extract z-entry order"  << "\n";
		std::cout << "\t" 	<< "--sPos"   << " dsPos"   << "\n";
		std::cout << "\t\t" << "Extract slice position in [m]"  << "\n";
		std::cout << "\t\t" << "if --sOrder and --sPos are all" << "\n";
		std::cout << "\t\t"	<< "defined, --sOrder is used by " << argv[0] << "\n";
		std::cout << "\t" 	<< "--zPos"   << " dzPos"   << "\n";
		std::cout << "\t\t" << "Extract zentry position in [m]" << "\n";
		std::cout << "\t\t" << "if --zOrder and --zPos are all" << "\n";
		std::cout << "\t\t"	<< "defined, --zOrder is used by " << argv[0] << "\n";
		std::cout << std::endl;
		exit(1);
	}
}

