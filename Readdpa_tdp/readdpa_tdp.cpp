/****************************************************************************\
This program is written for reading TDP .dpa file

Uasge: readdpa_tdp old_dpafile new_dpafile total_slices

Note: iotail must be 1, unless the total slice number will not be the same as nslice.

Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: 12:20, May. 31th, 2012
\****************************************************************************/

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <vector>
#include <cmath>
#include "methods.h"

using namespace std;

int main(int argc, char **argv)
{
	if(argc != 7)
	{
		if (argc > 1) cout << "Not enough parameters!\n";
		cout << "Usage: " << argv[0] << " file1 file2 total_slice total_charge xlamds nharm\n";
		cout << "\t" << "file1: " << "\t\t" << "dpa file to be read\n";
		cout << "\t" << "file2: " << "\t\t" << "current file\n";
		cout << "\t" << "total_slice: " << "\t" << "total slice number of dpa file\n";
		cout << "\t" << "total_charge: " << "\t" << "total bunch charge in [pC]\n";
		cout << "\t" << "xlamds: " << "\t" << "wavelength [nm]\n";
		cout << "\t" << "nharm: "  << "\t\t" << "for bunching factor calculation\n\n";
		exit(1);
	}

	string file1    = argv[1];  // dpa file name to read, old dpa file
	string file2    = argv[2];  // current file to write in
	unsigned int 	total_slices = atoi(argv[3]); 		// total slice number of dpa file
	double 			total_charge = atof(argv[4])*1e-12; // total charge [pC]->[C]
	double 			xlamds = atof(argv[5])*1e-9; 		// wavelength [nm]->[m]
//	int 			zsep   = atoi(argv[6]); 			// slice separation length by unit of xlamds
	int 			nharm  = atoi(argv[6]); 			// harmonic number for bunching factor calculation

	fstream  oldfile(file1.c_str(), ios::in  | ios::binary);
	ofstream newfile(file2.c_str());


	if (!oldfile || !newfile) 	// if any one of files cannot open, return error, exit
	{
		cout << "Open file error!\n\n";
		exit(1);
	}

	// read oldfile into vector a (all the particles, datasize: nslice*npart*6)
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
	cout << data_count << " data read.\n";

	unsigned int npart = data_count/6/total_slices; // total particle number
	cout << "npart = " << npart << endl;


	// extract theta (t0) column, total: npart*nslice (data_count/6)

	double *t0 = new double [data_count/6];

	double k0 = 2*PI/xlamds;

	unsigned int n = 0;
	ofstream tout("tmpt");
	for(unsigned int i = 0; i < total_slices; i++)
	{
		for(unsigned int j = (6*i+1)*npart; j < (6*i+2)*npart; j++)
		{
			t0[n] = a[j]/k0/C0;
			tout << a[j] << endl;
			n++;
		}
	}
	tout.close();
	cout << "n = " << n << endl;

	// split slices

	post_process slice_analysis;
	int nbins = total_slices;
	slice_analysis.set_nbins    (nbins);
	slice_analysis.set_pCharge  (total_charge);
	slice_analysis.set_dataSize (n);
	slice_analysis.set_data     (t0);
	
	double *histc_x1 = new double [nbins];
	double *histc_x2 = new double [nbins];
	double *histc_y  = new double [nbins];
	
	double peakcurrent = slice_analysis.get_peakCurrent();
	double bunching = slice_analysis.get_bunching(nharm, xlamds);

	histc_x1 = slice_analysis.get_histc_x1();
	histc_x2 = slice_analysis.get_histc_x2();
	histc_y  = slice_analysis.get_histc_y ();

	double   delt = slice_analysis.get_binWidth();
	unsigned totN = slice_analysis.get_dataSize();
	double   totC = slice_analysis.get_pCharge ();
	double   coef = totC/totN/delt;

	newfile.precision(16);
	newfile.width(24);
	newfile << std::left;

	cout << "Peak Current: "    << peakcurrent << " Amp" << endl;
	cout << "Bunching factor: " << bunching    << endl;

	newfile << "#Peak Current: "    << peakcurrent 	<< " Amp"  << endl;
	newfile << "#Bunching factor: " << bunching    	<< 	endl;
	newfile << "#Total Charge: " 	<< totC 		<< " C"    << endl;
	newfile << "#Total Particle: "  << totN 		<< 	endl;
	newfile << "#slice width: " 	<< delt 		<< " sec"   << endl;

	newfile << std::scientific;
	for(unsigned int i = 0; i < nbins; i++)
	{
		newfile << histc_x1[i] << " " << histc_x2[i] << " " << histc_y[i] << " " << histc_y[i]*coef << "\n";
	}

	oldfile.close();
	newfile.close();

	return 0;
}

