/*
This is the main program of laser-beam interaction in a magnetic element.
Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: Sep. 10th, 2011
Usage: main namelist
	 main: the compiled executable program
 namelist: file contains parameter setup, see namelist.example
*/

#include <iostream>
#include <fstream>
#include <map>
#include <cstdlib>
#include "element.h"
#include "readinput.h"
#include "interaction.h"

using namespace std;

int main(int argc, char *argv[])
{
	map<string, string> var; 	// store read variable map structure from external file
	seedlaser   param_seed; 	// seedlaser class
	dipole      param_dipole; 	// dipole class
	undulator   param_undulator;// undulator class
	elementType param_eletype; 	// element type
	scanPanel   param_scan; 	// scanPanel type

	ifstream file; 				// namelist external file
	file.open(argv[1]); 		// open namelist file
	getfield(file, var); 		// get all variables from external file
//	printlist(var); 			// print namelist from external file

	set_seedlaser  (param_seed   , var); // set seedlaser parameters
	set_elementType(param_eletype, var); // set element type
	set_scanPanel  (param_scan   , var); // set scanPanel
	unsigned int flag = set_whichelement(param_eletype, param_dipole, param_undulator, var); // flag, 0: dipole, 1: undulator
//	cout << param_eletype.get_print();

	if(param_eletype.get_print())
	{
		param_eletype.printall(); // print elementType
		param_scan.printall();    // print scanPanel
		printallvar(flag, param_seed, param_dipole, param_undulator); // print variable list currently used
	}

	// initialize file streams
	ifstream infile;
	ofstream outfile;
	set_filestream  (infile, outfile, var);
	check_filestream(infile, outfile);

	double *s0, *gam0, *x0, *y0, *vx0, *vy0; // initialize 6 1D arrays to dipct 6D phase space
	readdata(infile, param_eletype, s0, gam0, x0, y0, vx0, vy0); // read initial phase space

	if(param_scan.get_sflag())
	{
		performScan(outfile, param_scan, param_eletype, param_seed, param_dipole, param_undulator, var, flag, s0, gam0, x0, y0, vx0, vy0);
	}
	else
	{
		cout << "rms delta_gam: " << interactDump(outfile, param_eletype, param_seed, param_dipole, param_undulator, flag, s0, gam0, x0, y0, vx0, vy0) << endl; // modulating in a flag defined magnetic element
	}

	unset_filestream(infile, outfile); // close file streams

	return 0;

}
