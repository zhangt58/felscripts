#ifndef _INTERACTION_H
#define _INTERACTION_H

#include <fstream>
#include <string>
#include <map>
#include "element.h"

double func_mean(double *a, int size); // return the mean value of array a with a given size

void readdata(std::ifstream &infile, elementType &param_eletype, double *&s0, double *&gam0, double *&x0, double *&y0, double *&vx0, double *&vy0); // read data from ifstream infile, and store in 6 1D array (s0, gam0, x0, y0, vx0, vy0), respectively

double interactDump(std::ofstream &outfile, elementType &param_eletype, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, unsigned int flag, double *s0, double *gam0, double *x0, double *y0, double *vx0, double *vy0); // laser and e-beam interaction in a dipole( flag = 0 ) or undulator( flag = 1 ), return the whole rms modulation amplitude(sigma_delta_gamma), write the final 6D phase space to specified filestream

double interactNotDump(elementType &param_eletype, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, unsigned int flag, double *s0, double *gam0, double *x0, double *y0, double *vx0, double *vy0); // laser and e-beam interaction in a dipole( flag = 0 ) or undulator( flag = 1 ), return the whole rms modulation amplitude(sigma_delta_gamma)

void performScan(std::ofstream &outfile, scanPanel &param_scan, elementType &param_eletype, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, std::map<std::string, std::string> & var, unsigned int flag, double *s0, double *gam0, double *x0, double *y0, double *vx0, double *vy0); // do parameter scanning, and parameters which can be scanned are:
//seedlaser: 			|	dipole: 				| 	undulator:
// 	seed_wavelength; 	| 		dipole_field; 		| 		undulator_period;
// 	seed_power; 		| 		dipole_length; 		| 		undulator_field;
// 	seed_tau; 			| 							| 		undulator_num;
//  seed_ceo; 			| 							|
// 	seed_omega0; 		| 							|
// 	seed_offset; 		| 							|

void check_scansetup(std::string scanparam, double scanbegin, double scanstep, double scanend); // check if scanpanel set correctly

int check_scanparam(std::string scanparam); //check scan parameter name, 1: correct, 0: wrong

#endif
