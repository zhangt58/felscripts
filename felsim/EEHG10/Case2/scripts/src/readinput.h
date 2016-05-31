#include <string>
#include <fstream>
#include <map>
#include "element.h"

void trimline(std::string &str); // trim leading and tailing spaces(include " and ') of a string
void getfield(std::ifstream &infile, std::map <std::string, std::string> & var); 	// get variable names the corresponding values
void printlist(std::map <std::string, std::string> & var);  					// print map record one by one
void set_elementType(elementType &param_ele      , std::map <std::string, std::string> & var); 			// set element type
void set_scanPanel  (scanPanel   &param_scan     , std::map <std::string, std::string> & var); 			// set scanPanel class
void set_seedlaser  (seedlaser   &param_seed     , std::map <std::string, std::string> & var); 			// set seedlaser class
void set_dipole     (dipole      &param_dipole   , std::map <std::string, std::string> & var); 			// set dipole class
void set_undulator  (undulator   &param_undulator, std::map <std::string, std::string> & var); 			// set undulator class
void set_filestream  (std::ifstream &infile, std::ofstream &outfile, std::map <std::string, std::string> & var); 	// set (open) input and output file names
void check_filestream(std::ifstream &infile, std::ofstream &outfile); // check if file open correctly
void unset_filestream(std::ifstream &infile, std::ofstream &outfile); // close file streams
unsigned int set_whichelement(elementType &param_eletype, dipole &param_dipole, undulator &param_undulator, std::map <std::string, std::string> & var); // choose which element to setup, return 0 if 'dipole', 1 if 'undulator'
void printallvar(unsigned int flag, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator); // print all read variable from namelist external file, categorize by class
void refresh_var(std::string vname, double value, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, std::map <std::string, std::string> & var); // reset all parameters when do scanning
std::string dbl2str(double &x); // convert double to string
