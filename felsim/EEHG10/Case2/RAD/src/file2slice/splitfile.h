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

#ifndef _SPLITFILE_H
#define _SPLITFILE_H

#include <fstream>
static const double C0 = 299792458.0;
static const double PI = 3.141592653589793;

// read data from infile and store into six arraies
void readdata(std::ifstream &infile, unsigned int npart, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0);

// for sort index
bool compFunc(double *lhs, double *rhs); 	// compare function of sort
unsigned int *sortIndex(double* &a, int n); // n: size of array a

unsigned int findMaxCount(double* &t0, unsigned int* &idx, unsigned int &slices, double &slice_width, double &t0_max, double &t0_min, unsigned int &npart); // return the max count number of all the bins

// split with the defined number of splitted files
void dumpSlicesN(std::string &filehead, unsigned int &slices, unsigned int &npart, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0);

// (ascii) split with the defined the spacing of each splitted file as the first cols (t0)
void dumpSlicesD_asc(std::string &filehead, double &xlamds, unsigned int &delN, unsigned int &npart, std::string &coltyp, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0);

// (binary) split with the defined the spacing of each splitted file as the first cols (t0)
void dumpSlicesD_bin(std::string &filehead, double &xlamds, unsigned int &delN, unsigned int &npart, std::string &coltyp, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0);


template <class T>
std::string num2str(T x); // convert number to string for length detection

void checkParams(int argc, char* argv[]); // give warning when the parameter is not correct
int parseOpts(int argc, char* argv[], std::string &infilename, std::string &filehead, std::string &ofmt, std::string &coltyp, unsigned int &npart, unsigned int &deltN, double &xlamds); // parse options


#endif //_SPLITFILE_H
