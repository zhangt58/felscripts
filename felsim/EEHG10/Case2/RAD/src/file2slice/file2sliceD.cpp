/*********************************************************************\
 * Program: file2sliceD                                              *
 * Purpose: split a single datafile into slices for GENESIS 1.3      *  
 * Copyright (C) 2012 Tong Zhang                                     *
 *                                                                   *
 * This file is part of file2sliceD.                                 *
 *                                                                   *
 * file2sliceD is free software: you can distribute it and/or modify *
 * it under the terms of GNU General Public License as published by  *
 * the Free Software Foundation, either version 3 of the License or  *
 * (at your option) any later version.                               *
 *                                                                   *
 * file2sliceD is distributed in the hope that it will be useful,    *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of    *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      *
 * GNU General Public License for more details.                      *
 *                                                                   *
 * You should have received a copy of the GNU General Public License *
 * along with file2sliceD. If not see <http://www.gnu.org/licenses/>.*
\*********************************************************************/

/*
This program is written for split a single file into multifiles, according to the numberic value of the 1st column of inputfile, each outfile has the same range of 1st column

USAGE: file2sliceD  --infile infile \
					--npart npart \
					--xlamds xlamds \
					--delt N \
					--outprefix filehead \
					--outformat (bin|asc) \
					--coltype (genesis|elegant) \
					--showtype

	where xlamds is the wavelength, N is the separation length of col_t by unit of xlamds.
	the output will be sorted series files with the naming rule of 'head'+order..., where head can be defined by option --outprefix

Author: Tong ZHANG
E-mail: tzhang@sinap.ac.cn
Created Time: 14:27, Sep. 30th, 2011
Modified Time: 11:15, Sep. 6th, 2012
*/

#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include "splitfile.h"

using namespace std;

int main(int argc, char* argv[])
{

	checkParams(argc, argv);

	// parse option flags
	string infilename; 			// input filename
	string filehead = "slice"; 	// output filehead
	string ofmt = "bin"; 		// output file format
	string coltyp = "genesis"; 	// output cols type
	double xlamds; 				// wavelength [m]
	unsigned int npart;			// size of datafile (wc -l)
	unsigned int delN = 1; 		// spacing of each slice, by unit of xlamds
	if(!parseOpts(argc, argv, infilename, filehead, ofmt, coltyp, npart, delN, xlamds))
	{
		cerr << "Unknown flags, please check!\n";
		exit(1);
	}

	// open infile
	ifstream infile(infilename.c_str()); 	// open datafile to be splitted


	// six arraies for storing the reading data from infile
	double *t0     = new double [npart];
	double *gam0   = new double [npart];
	double *x0     = new double [npart];
	double *y0     = new double [npart];
	double *betax0 = new double [npart];
	double *betay0 = new double [npart];

	readdata(infile, npart, t0, gam0, x0, y0, betax0, betay0);
	
	// split all the data into files with the name of filehead+order
	if(ofmt == "bin") // binary
		dumpSlicesD_bin(filehead, xlamds, delN, npart, coltyp, t0, gam0, x0, y0, betax0, betay0);
	else // ascii
		dumpSlicesD_asc(filehead, xlamds, delN, npart, coltyp, t0, gam0, x0, y0, betax0, betay0);

	cout << "Slicing Done!" << "\n";
	cout << "Check info in file binCount..." << endl; 

	// reclaim heap memory
	delete[] t0;
	delete[] gam0;
	delete[] x0;
	delete[] y0;
	delete[] betax0;
	delete[] betay0;


	return 0;
}
