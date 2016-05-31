/*********************************************************************\
 * Program: getdp_z                                                  *
 * Purpose: extract z-order data info from the GENESIS output result *  
 * Copyright (C) 2012 Tong Zhang                                     *
 *                                                                   *
 * This program is free software: you can distribute it and/or modify*
 * it under the terms of GNU General Public License as published by  *
 * the Free Software Foundation, either version 3 of the License or  *
 * (at your option) any later version.                               *
 *                                                                   *
 * This program is distributed in the hope that it will be useful,   *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of    *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      *
 * GNU General Public License for more details.                      *
 *                                                                   *
 * You should have received a copy of the GNU General Public License *
 * along with this program. If not see <http://www.gnu.org/licenses/>.*
\*********************************************************************/

/******************************************************************************\
This program is written for parsing output file (TDP)

***get all slice value at given z-record

Usage: getdp file1 file2 z_order
	file1: output file (TDP)
	file2: write into the extrated data
	z_order: z-record order

Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: 14:58, Dec. 9th, 2011
\*******************************************************************************/

#include <iostream>
#include "getdp_fun.h"

using namespace std;

int main(int argc, char **argv)
{

	if(argc != 4) // if the number of parameters is not enough, then give errors, exit
	{
		if(argc >=2)cout << "Not enough parameters!\n\n";
		cout << "Usage: " << argv[0] << " file1 file2 z-pos\n";
		cout << "\t" << "file1: " << "\t" << "TDP output filename, open to read\n";
		cout << "\t" << "file2: " << "\t" << "data filename, open to write\n";
		cout << "\t" << "z-pos:"  << "\t" << "z-pos in unit of [m]\n\n";
		exit(1);
	}

	string file1name = argv[1]; // tdp filename to read
	string file2name = argv[2];	// filename for writting data

	ifstream file1;
	ofstream file2;

	double z_pos = atof(argv[3]); // z-pos in [m]
	string keystr1 = "delz";
	string keystr2 = "xlamd";
	double delz  = findMainKeyValue(file1name, keystr1);
	double xlamd = findMainKeyValue(file1name, keystr2);
	int z_order = z_pos/(delz*xlamd)+1; 	// transform z-pos into z-record order
	
	file1.open(file1name.c_str(), ifstream::in);
	file2.open(file2name.c_str(), ofstream::out);

	if (!file1 || !file2) 			// if any one of files cannot open, return error, exit
	{
		cout << "Open file error!\n\n";
		exit(1);
	}

	int count = 0; // read line by line, increase count value when encounter line starts with "*", means find one slice record
	while (!file1.eof()) // do not stop reading untile the end of file1 
	{
		// locate the beginning of every slice [s-order]
		while (1)
		{
			char buf[MAX_CHARS_PER_LINE];
			file1.getline(buf, MAX_CHARS_PER_LINE);
			char* token[MAX_TOKENS_PER_LINE] = {0};
			token[0] = strtok(buf, DELIMITER.c_str());
			if (token[0] && token[0][0]=='*')
			{
				count++;
				break;
			}
		}

		//pass next 5 useless lines
		string line;
		for (int i =1; i<=5; i++)
		{
			getline(file1, line);
			//file2 << line << "\n";
		}
		
		//extract the [slice_order]th z-record, given that line_count = z_order
		int line_count = 0;
		getline(file1, line);
		while (!line.empty())
		{
			line_count++;
			if (line_count==z_order) file2 << line << "\n";
			getline(file1, line);
		}
	}

	//close opened files
	file1.close();
	file2.close();

	return 0;
}
