#include<iostream>
#include<cstdlib>
#include<cstring>
#include<fstream>

using namespace std;

const int MAX_CHARS_PER_LINE  = 512;
const int MAX_TOKENS_PER_LINE = 20;
const string DELIMITER = " \t=";

//double findKeywordValue(ifstream &infile, string &keystr);
double findKeywordValue(string &file1, string &keystr);
// keystr list:
// entries
// history
// wavelength
// seperation
// meshsize
//

//double findMainKeyValue(ifstream &infile, string &keystr);
double findMainKeyValue(string &infile, string &keystr);

string dToE(string str1);

int main(int argc, char** argv)
{
//	ifstream infile(argv[1]);
	string infile = argv[1];
//	if (!infile)
//	{
//		cout << "File opening error!\n";
//		exit(1);
//	}
	char buf[MAX_CHARS_PER_LINE];
	int tokenCnt;
	string keystr1="seperation";
	string keystr2="delz";
	string keystr3="xlamd";

	cout << keystr1 << ": " << findKeywordValue(infile, keystr1) << endl;
	cout << keystr2 << ": " << findMainKeyValue(infile, keystr2) << endl;
	cout << keystr3 << ": " << findMainKeyValue(infile, keystr3) << endl;
	
	return 0;
}

double findKeywordValue(string &file1, string &keystr)
{
	ifstream infile;
	infile.open(file1.c_str(), std::ifstream::in);
	char buf[MAX_CHARS_PER_LINE];
	int tokenCnt;
	char* tokenTmp1;
	char* tokenTmp2;
	while (!infile.eof())
	{
		infile.getline(buf, MAX_CHARS_PER_LINE);
		char* token = strtok(buf, DELIMITER.c_str());
		if (token)
		{
			tokenTmp1 = token;
			if((tokenTmp2 = strtok(NULL, DELIMITER.c_str())) && !strcmp(tokenTmp2, keystr.c_str())) 
			{
				//cout << tokenTmp1 << endl;
				break;
			}
		}
	}
	infile.close();
	return atof(tokenTmp1);
}

double findMainKeyValue(string &file1, string &keystr)
{
	ifstream infile;
	infile.open(file1.c_str(), std::ifstream::in);
	char buf[MAX_CHARS_PER_LINE];
	int tokenCnt;
	char* tokenTmp1;
	char* tokenTmp2;
	string DELIMITER1 = " \t=";
	while (!infile.eof())
	{
		infile.getline(buf, MAX_CHARS_PER_LINE);
		char* token = strtok(buf, DELIMITER1.c_str());
		if (token)
		{
			tokenTmp1 = token;
			if(!strcmp(tokenTmp1, keystr.c_str()) && (tokenTmp2 = strtok(NULL, DELIMITER1.c_str()))) 
			{
				//cout << tokenTmp2 << endl;
				break;
			}
		}
	}
	infile.close();
	return atof(dToE(string(tokenTmp2)).c_str());
}

std::string dToE(string str1)
{
//	std::size_t pos = str1.find("D");
	str1.replace(str1.find("D"),1,"E");
	return str1;
}
