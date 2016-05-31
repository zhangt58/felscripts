/*********************************************************************\
 * Program: phaseshift                                               *
 * Purpose: simulating the phase-shifting when e- pass phase-shifter *  
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>*
\*********************************************************************/

/****************************************************************************\
This program is written for modifying the theta col of a binary format file.

Uasge: phaseshift old_dpafile new_dpafile total_slices delta_theta

Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: 21:12, Dec. 8th, 2011
\****************************************************************************/

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <vector>

using namespace std;

int main(int argc, char **argv)
{
	if(argc !=5)
	{
		if(argc >1)cout << "Not enough parameters!\n";
		cout << "Usage: " << argv[0] << " file1 file2 total_slice delphi\n";
		cout << "\t" << "file1: " << "\t\t" << "dpa file to be manipulated\n";
		cout << "\t" << "file2: " << "\t\t" << "dpa file after manipulated\n";
		cout << "\t" << "total_slice: " << "\t" << "total slice number of dpa file\n";
		cout << "\t" << "delphi: " << "\t" << "additional phase to be added[rad]\n\n";
		exit(1);
	}

	string file1    = argv[1];  // dpa file name to read, old dpa file
	string file2    = argv[2];  // phase-shifted dpa file name to write in
	unsigned int total_slices= atoi(argv[3]); // total slice number of dpa file
	double delphi   = atof(argv[4]); // phase-shifted value, [rad]

	fstream oldfile(file1.c_str(), ios::in  | ios::binary);
	fstream newfile(file2.c_str(), ios::out | ios::binary);


	if (!oldfile || !newfile) 	// if any one of files cannot open, return error, exit
	{
		cout << "Open file error!\n\n";
		exit(1);
	}

	// read oldfile into vector a
	vector <double> a; 
	double temp;
	unsigned int data_count=0;
	oldfile.read((char*)&temp, sizeof(double));
	do
	{
		a.push_back(temp);
		oldfile.read((char*)&temp, sizeof(double));
		data_count++;
	}while(!oldfile.eof());
	oldfile.close();
//	cout << data_count << " data read.\n";

	unsigned int npart = data_count/6/total_slices; // total particle number
	//
	//write modified data into newfile
	
	for(unsigned int i=0; i<total_slices; i++)
	{
		for(unsigned int j=(6*i+1)*npart; j<(6*i+2)*npart; j++)
			a[j]+=delphi;
	}

	for(unsigned int i=0; i<data_count; i++)
		newfile.write((char*)&(a[i]), sizeof(double));
	
	oldfile.close();
	newfile.close();

	return 0;
}

