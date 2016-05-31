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

#include "splitfile.h"
#include <algorithm>
#include <sstream>
#include <ostream>
#include <vector>
#include <iostream>
//#include <fstream>

void readdata(std::ifstream &infile, unsigned int npart, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0)
{
	double *ptrt0     = new double [npart];
	double *ptrgam0   = new double [npart];
	double *ptrx0     = new double [npart];
	double *ptry0     = new double [npart];
	double *ptrbetax0 = new double [npart];
	double *ptrbetay0 = new double [npart];
	for(unsigned int i = 0; i < npart; i++)
	{
		infile >> ptrt0[i];
		infile >> ptrgam0[i];
		infile >> ptrx0[i];
		infile >> ptry0[i];
		infile >> ptrbetax0[i];
		infile >> ptrbetay0[i];
	}
	infile.close();
	t0 	   = ptrt0;
	gam0   = ptrgam0;
	x0 	   = ptrx0;
	y0 	   = ptry0;
	betax0 = ptrbetax0;
	betay0 = ptrbetay0;
}

//for sort index
bool compFunc(double *lhs, double *rhs)
{
//	return *lhs < *rhs;
	return *lhs > *rhs; //sort from head to tail
}

unsigned int *sortIndex(double* &a, unsigned int n)
{
	double **p = new double* [n]; // n: size of array a
	// point array which each element is a point points to an element of a array
	unsigned int *idx = new unsigned int [n]; 
	// array to store the sorted index
	for(unsigned int i = 0; i < n; i++)
		p[i]=&a[i];  // p[i] is the address of a[i]
	std::sort(p,p+n,compFunc); 
	// sort p array, i.e. a[i]'s address, apply compFunc rule, that is compare the pointed value, i.e. a[i], but a keeps the same, only their point is sorted
	for(unsigned int i = 0; i < n; i++)
		idx[i] = (int)(p[i]-a); // calculate the difference between sort-before and sort-after
	return idx;
}

/*
void dumpSlicesN(std::string &filehead, unsigned int &slices, unsigned int &npart, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0)
{
	unsigned int *idx = new unsigned int [npart];
	idx = sortIndex(t0, npart); // get the sorted index, reference element by a[idx[i]]
	double t0_max = *(t0+idx[npart-1]); // the maximum of t0[]
	double t0_min = *(t0+idx[0]); 	  // the minimum of t0[]
	double slice_width = (t0_max - t0_min)/(double)slices;

//	std::ofstream ftmp("idxout");
//	for(unsigned int i =0;i<npart;i++)
//		ftmp << idx[i] << "\n";
//	ftmp.close();
//	std::cout << t0_max << std::endl;
//	std::cout << t0_min << std::endl;

	double level_slice_low, level_slice_up;
	level_slice_low = t0_min;
	unsigned int slicenum = 1, j = 0, count_n;
	std::string ofilename;
	std::stringstream sstr;

	std::ofstream countfile("binCount");

	while(slicenum <= slices)
	{
		sstr << filehead << slicenum;
		ofilename = sstr.str();
		std::ofstream ofilename(sstr.str().c_str()); // open ofilename[slicenum]
		count_n = 0;
		level_slice_up = level_slice_low + slice_width;
		while(j < npart && *(t0+idx[j]) < level_slice_up)
		{
			// write data line by line
			ofilename << std::scientific;
			ofilename << std::left;
			ofilename.precision(16);
			ofilename << *(t0     + idx[j]) << " "
					  << *(gam0   + idx[j]) << " "
					  << *(x0     + idx[j]) << " "
					  << *(y0     + idx[j]) << " "
					  << *(betax0 + idx[j]) << " "
					  << *(betay0 + idx[j]) << "\n";
			count_n++;
			++j;
		}
		sstr.str("");
		ofilename.close();
		level_slice_low = level_slice_up;
		++slicenum;
		countfile << count_n << "\n";
	}
	countfile.close();
}
*/

unsigned int findMaxCount(double* &t0, unsigned int* &idx, unsigned int &slices, double &slice_width, double &t0_max, double &t0_min, unsigned int &npart) // return the max count number of all the bins
{
	double level_slice_low, level_slice_up;
	level_slice_up = t0_max;
	unsigned int slicenum = 0, j = 0, count_n, max_cnt = 0;
	while(slicenum < slices)
	{
		count_n = 0;
		level_slice_low = level_slice_up - slice_width;
		while(j < npart && *(t0+idx[j]) > level_slice_low)
		{
			count_n++;
			++j;
		}
		if(count_n > max_cnt) max_cnt = count_n;
		level_slice_up = level_slice_low;
		++slicenum;
	}
	return max_cnt;
}

void dumpSlicesD_asc(std::string &filehead, double &xlamds, unsigned int &delN, unsigned int &npart, std::string &coltyp, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0)
{
	unsigned int *idx = new unsigned int [npart];
	idx = sortIndex(t0, npart); // get the sorted index, reference element by a[idx[i]]
	double t0_min = *(t0+idx[npart-1]); // the minimum of t0[], tail
	double t0_max = *(t0+idx[0]); 	    // the maximum of t0[], head
	double slice_width = (double)(xlamds*delN/C0);
	unsigned int slices = (unsigned int)((t0_max-t0_min)/slice_width) + 1; // total slice number

// go through the whole file, figure out the max bin-count	
//	unsigned int maxcnt = findMaxCount(t0, idx, slices, slice_width, t0_max, t0_min, npart);
//	std::cout << maxcnt << std::endl;
		
	double level_slice_low, level_slice_up;
	level_slice_up = t0_max;
	unsigned int slicenum = 1, j = 0, count_n;
	std::string ofilename; 		// output filename
	std::stringstream sstr;

	sstr << "binInfo_" << filehead;
	std::ofstream countfile(sstr.str().c_str()); 	// bin_info filename
	sstr.str(std::string());

	countfile << "# Total slice number: " << slices 	 << "\n";
	countfile << "# Slice width [sec] : " << slice_width << "\n";
	countfile << "                                           \n";
	countfile << "# Slice countings are: "<< "\n";


	unsigned int total_count = 0; // count the total splitted number
	while(slicenum <= slices)
	{
		sstr << filehead << slicenum;
		ofilename = sstr.str();
		std::ofstream ofilename(sstr.str().c_str()); // open ofilename[slicenum]
		count_n = 0;
		level_slice_low = level_slice_up - slice_width;
		while(j < npart && *(t0+idx[j]) > level_slice_low)
		{
			// write data line by line
			ofilename << std::scientific;
			ofilename << std::left;
			ofilename.precision(16);
			if(coltyp == "genesis")
			{
				ofilename << *(gam0   + idx[j]) << " " 					 // gamma
						  << *(t0     + idx[j])*C0*2*PI/xlamds << " " 	 // theta
						  << *(x0     + idx[j]) << " " 					 // x
						  << *(y0     + idx[j]) << " " 					 // y
						  << *(betax0 + idx[j]) * *(gam0+idx[j]) << " "  // xp
						  << *(betay0 + idx[j]) * *(gam0+idx[j]) << "\n";// yp
				count_n++; total_count++;
				++j;
			}
			else
			{
				ofilename << *(t0     + idx[j]) << " " 		// t
						  << *(gam0   + idx[j]) << " " 		// gamma
						  << *(x0     + idx[j]) << " " 		// x
						  << *(y0     + idx[j]) << " " 		// y
						  << *(betax0 + idx[j]) << " " 		// betax
						  << *(betay0 + idx[j]) << "\n";	// betay
				count_n++; total_count++;
				++j;
			}
		}
		sstr.str("");
		ofilename.close();
		level_slice_up = level_slice_low;
		countfile << "slice_" << slicenum << "_count: " << count_n << "\n";
		++slicenum;
	}

	// seekp to the third line
	countfile.seekp(45+num2str(slices).length()+num2str(slice_width).length(),std::ios::beg);
	countfile << "\n# Total counting is: " << total_count << std::endl;
	countfile.close();
}

void dumpSlicesD_bin(std::string &filehead, double &xlamds, unsigned int &delN, unsigned int &npart, std::string &coltyp, double* &t0, double* &gam0, double* &x0, double* &y0, double* &betax0, double* &betay0)
{
	unsigned int *idx = new unsigned int [npart];
	idx = sortIndex(t0, npart); // get the sorted index, reference element by a[idx[i]]
	double t0_min = *(t0+idx[npart-1]); // the minimum of t0[], tail
	double t0_max = *(t0+idx[0]); 	    // the maximum of t0[], head
	double slice_width = (double)(xlamds*delN/C0);
	unsigned int slices = (unsigned int)((t0_max-t0_min)/slice_width) + 1; // total slice number

	double level_slice_low, level_slice_up;
	level_slice_up = t0_max;
	unsigned int slicenum = 1, j = 0, count_n;
	std::string ofilename; 		// output filename
	std::stringstream sstr;

	sstr << "binInfo_" << filehead;
	std::ofstream countfile(sstr.str().c_str()); 	// bin_info filename
	sstr.str(std::string());

	countfile << "# Total slice number: " << slices 	 << "\n";
	countfile << "# Slice width [sec] : " << slice_width << "\n";
	countfile << "                                           \n";
	countfile << "# Slice countings are: "<< "\n";


	unsigned int total_count = 0; // count the total splitted number
	double tmp;
	while(slicenum <= slices)
	{
		sstr << filehead << slicenum;
		ofilename = sstr.str();
		std::ofstream ofilename(sstr.str().c_str(), std::ios::binary); // open ofilename[slicenum] as binary writing mode
		count_n = 0;
		level_slice_low = level_slice_up - slice_width;

		std::vector <int> idxbk; // size of idxbk: count_n (i.e. slice count)
		if (coltyp == "genesis")
		{
			// write gamma
			while(j < npart && *(t0+idx[j]) > level_slice_low)
			{
				ofilename.write((char*)(gam0+idx[j]), sizeof(double));
				count_n++; total_count++;
				idxbk.push_back(idx[j]);
				++j;
			}

			// write theta
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				tmp = *(t0+idxbk[i])*C0*2*PI/xlamds;
				ofilename.write((char*)&tmp, sizeof(double));
			}

			// write x
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				ofilename.write((char*)(x0+idxbk[i]), sizeof(double));
			}

			// write y
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				ofilename.write((char*)(y0+idxbk[i]), sizeof(double));
			}
			
			// write xp
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				tmp = *(betax0+idxbk[i]) * *(gam0+idxbk[i]);
				ofilename.write((char*)&tmp, sizeof(double));
			}
			
			// write yp
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				tmp = *(betay0+idxbk[i]) * *(gam0+idxbk[i]);
				ofilename.write((char*)&tmp, sizeof(double));
			}

		}
		else // elegant
		{
			// write t
			while(j < npart && *(t0+idx[j]) > level_slice_low)
			{
				ofilename.write((char*)(t0+idx[j]), sizeof(double));
				count_n++; total_count++;
				idxbk.push_back(idx[j]);
				++j;
			}

			//write gamma
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				ofilename.write((char*)(gam0+idxbk[i]), sizeof(double));
			}

			// write x
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				ofilename.write((char*)(x0+idxbk[i]), sizeof(double));
			}

			// write y
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				ofilename.write((char*)(y0+idxbk[i]), sizeof(double));
			}
			
			// write betax
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				ofilename.write((char*)(betax0+idxbk[i]), sizeof(double));
			}
			
			// write betay
			for(unsigned int i = 0; i < idxbk.size(); i++)
			{
				
				ofilename.write((char*)(betay0+idxbk[i]), sizeof(double));
			}

		}

			
		sstr.str("");
		ofilename.close();
		level_slice_up = level_slice_low;
		countfile << "slice_" << slicenum << "_count: " << count_n << "\n";
		++slicenum;
	}

	// seekp to the third line
	countfile.seekp(45+num2str(slices).length()+num2str(slice_width).length(),std::ios::beg);
	countfile << "\n# Total counting is: " << total_count << std::endl;
	countfile.close();
}

template <class T>
std::string num2str(T x)
{
	std::stringstream sstr;
	sstr << x;
	return sstr.str();
}

void checkParams(int argc, char* argv[])
{
	if(argc > 1 && argv[1] == std::string("--showtype"))
	{
		std::cout << "Columns type info:" << "\n";
		std::cout << "\t" << "type   : " << "|-col1-|-col2-|-col3-|-col4-|-col5-|-col6-|" << "\n";
		std::cout << "\t" << "genesis: " << "|-gamma|-theta|--x---|--y---|--xp--|--yp--|" << "\n";
		std::cout << "\t" << "elegant: " << "|---t--|-gamma|--x---|--y---|-betax|-betay|" << "\n";
		std::cout << "\t" << "where {x,y}p = beta{x,y}*gamma" << std::endl;
		exit(1);
	} else if(argc < 7)
	{
		std::cout << "Usage: " << argv[0] << " [--flag value] ..." << "\n";

		std::cout << "\n";

		std::cout << "Mandatory flags:" << "\n";
		std::cout << "\t" 	<< "--input" 	<< " infile" 	<< "\n";
		std::cout << "\t\t" << "datafile to be splitted" 	<< "\n";
		std::cout << "\t" 	<< "--npart" 	<< " npart" 	<< "\n";
		std::cout << "\t\t" << "total particle number" 		<< "\n";
		std::cout << "\t" 	<< "--xlamds" 	<< " xlamds" 	<< "\n";
		std::cout << "\t\t" << "wavelength [m]" 			<< "\n";

		std::cout << "\n";

		std::cout << "Optional flags:" <<"\n";
		std::cout << "\t" 	<< "--delt" 	<< " delN"  	<< "\n";
		std::cout << "\t\t" << "spacing between the contiguous slices by unit of xlamds," << "\n";
		std::cout << "\t\t" << "1 by default" << "\n";
		std::cout << "\t" 	<< "--outprefix" << " filehead" << "\n";
		std::cout << "\t\t" << "outfile naming rule: filehead+# or slice+# by default" << "\n";
		std::cout << "\t" 	<< "--outformat" << " (bin|asc)"<< "\n";
		std::cout << "\t\t" << "outfile format, binary or ascii,binary by default" << "\n";
		std::cout << "\t" 	<< "--coltype" 	 << " (genesis|elegant)" << "\n";
		std::cout << "\t\t" << "outfile cols type, genesis or elegant, genesis by default" << std::endl;

		std::cout << "\t" 	<< "--showtype" << "\n";
		std::cout << "\t\t" << "show the cols type of genesis or elegant info" << std::endl;

		std::cout << "\n";

		exit(1);
	}
}

int parseOpts(int argc, char* argv[], std::string &infilename, std::string &filehead, std::string &ofmt, std::string &coltyp, unsigned int &npart, unsigned int &delN, double &xlamds)
{
	for(int i = 1; i < argc-1; i+=2)
	{
		if(argv[i] == std::string("--input"))
			infilename = argv[i+1];
		else if(argv[i] == std::string("--npart"))
			npart = atoi(argv[i+1]);
		else if(argv[i] == std::string("--xlamds"))
			xlamds = atof(argv[i+1]);
		else if(argv[i] == std::string("--delt"))
			delN = atoi(argv[i+1]);
		else if(argv[i] == std::string("--outprefix"))
			filehead = argv[i+1];
		else if(argv[i] == std::string("--outformat"))
			ofmt = argv[i+1];
		else if(argv[i] == std::string("--coltype"))
			coltyp = argv[i+1];
		else
			return 0;
	}
	return 1; // parsing success!
}
