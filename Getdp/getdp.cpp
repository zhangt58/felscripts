/*********************************************************************\
 * Program: getdp                                                    *
 * Purpose: extract slice info from the GENESIS output result        *  
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

/*********************************************************************\
This program is written for parsing output file (TDP)

***Get the given slices z-value

Usage: getdp file1 file2 slice_order
	file1: output file (TDP)
	file2: write into the extrated data
	slice_order: slice record order

Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: 10:05, Dec. 9th, 2011
Last update:  22:38, May 25th, 2014
\*********************************************************************/

#include "getdp_fun.h"
#include <iostream>

using namespace std;

int main(int argc, char **argv)
{
	checkParams(argc,argv);

	string file1name, file2name;
	int isOrder = 0, izOrder = 0;
	int sFlag   = 0, zFlag   = 0;
	double dsPos = 0, dzPos = 0;
	
	if (!parseOpts(argc, argv, file1name, file2name, 
				   isOrder, dsPos, izOrder, dzPos, sFlag, zFlag))
	{
		cerr << "Unknown flags, please check!\n";
		exit(1);
	}

	ifstream file1;
	ofstream file2;

	if (sFlag)
	{
		if (dsPos) // given s-pos in meter
		{
			string keystr = "seperation";     // define the keyword string, to find its value
			double slice_sepe = findKeywordValue(file1name, keystr);
			isOrder = dsPos/slice_sepe+1; // transform s_pos into s-record order
		}

		file1.open(file1name.c_str(), ifstream::in);
		file2.open(file2name.c_str(), ofstream::out);

		if (!file1 || !file2) 			// if any one of files cannot open, return error, exit
		{
			cout << "Open file error!\n\n";
			exit(1);
		}

		// locate the slice [s-order]
		int count = 0; // read line by line, increase count value when encounter line starts with "*", untile count = s-order
		while (!file1.eof()) // do not stop reading untile the end of file1 
		{
			if (count==isOrder)break;
			char buf[MAX_CHARS_PER_LINE];
			file1.getline(buf, MAX_CHARS_PER_LINE);
			char* token[MAX_TOKENS_PER_LINE] = {0};
			token[0] = strtok(buf, DELIMITER.c_str());
			if(token[0] && token[0][0]=='*')count++;
		}

		//pass next 5 useless lines
		string line;
		for (int i =1; i<=5; i++)
		{
			getline(file1, line);
			//file2 << line << "\n";
		}

		//extract the [s-order]th slice, 'result v.s. z'
		getline(file1, line);
		while (!line.empty())
		{
			file2 << line << "\n";
			getline(file1, line);
		}

		//close opened files
		file1.close();
		file2.close();
	}

	if (zFlag)
	{
		if (dsPos)
		{
			string keystr1 = "delz";
			string keystr2 = "xlamd";
			double delz  = findMainKeyValue(file1name, keystr1);
			double xlamd = findMainKeyValue(file1name, keystr2);
			izOrder = dzPos/(delz*xlamd)+1; 	// transform z-pos into z-record order
		}

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
				if (line_count==izOrder) file2 << line << "\n";
				getline(file1, line);
			}
		}

		//close opened files
		file1.close();
		file2.close();
	}

	return 0;
}
