#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>
#include <string>

using namespace std;

const int MAX_CHARS_PER_LINE=256;
const int MAX_TOKENS_PER_LINE=10;
const string DELIMITER=" ";

int main(int argc, char** argv)
{
	ifstream infile("template.out",ifstream::in);
	string line, firtw;
	for(int i=1;i<=284;i++) getline(infile, line);
	
	char buf[MAX_CHARS_PER_LINE];
	infile.getline(buf, MAX_CHARS_PER_LINE);

	char* outline1 = strtok(buf, DELIMITER.c_str());
	cout << outline1<< endl;

	return 0;
}

