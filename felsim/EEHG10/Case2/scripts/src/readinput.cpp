#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include <map>
#include <iomanip>
#include "element.h"
#include "readinput.h"

using namespace std;

void trimline(string &str) // trim leading and tailing whitespaces or ",'
{
	size_t pos1, pos2;
	pos1 = str.find_first_not_of(" \t\n\"\';,");
	pos2 = str.find_last_not_of (" \t\n\"\';,");
	str  = str.substr(pos1, pos2-pos1+1);
}

void getfield(ifstream &infile, map<string, string>& var)
{
	string line, vname, value;
	while(getline(infile, line))
	{
		if(line.empty())continue;
		trimline(line);
		if(line[0] == '#' || line[0] == '!' || line[0] == '/')continue;
		istringstream sline(line);
		getline(sline, vname, '=');
		getline(sline, value, '=');
		trimline(vname);
		trimline(value);
		var[vname] = value.c_str();
	}
}

void printlist(map <string, string> & var)
{
	int i = 0;
	map <string, string> :: iterator it;
	for(it = var.begin(); it != var.end(); it++,++i)
		cout << left << setw(18) << it->first << " ==> " << setw(18) << setprecision(6)<< it->second << endl;
	cout << "------------------------------" << endl;
	cout << "Total " << i << " records printed.\n" << endl;
}

void set_elementType(elementType &param_ele, map <string, string> & var)
{
	param_ele.set_flag (var.find("use_element")->second);
	param_ele.set_print(atoi((var.find("print_list")->second).c_str()));
	param_ele.set_npart(atoi((var.find("npart")->second).c_str()));
}

void set_scanPanel(scanPanel &param_scan, map <string, string> & var)
{
	param_scan.set_sparam(      var.find("scan_param")->second);
	param_scan.set_sflag (atoi((var.find("scan_flag" )->second).c_str()));
	param_scan.set_secho (atoi((var.find("scan_echo" )->second).c_str()));
	param_scan.set_sbegin(atof((var.find("scan_begin")->second).c_str()));
	param_scan.set_sstep (atof((var.find("scan_step" )->second).c_str()));
	param_scan.set_send  (atof((var.find("scan_end"  )->second).c_str()));
}


void set_seedlaser(seedlaser &param_seed, map <string, string> & var)
{
	param_seed.set_wavelength(atof((var.find("seed_wavelength")->second).c_str()));
	param_seed.set_peakpower (atof((var.find("seed_power"     )->second).c_str()));
	param_seed.set_tau       (atof((var.find("seed_tau"       )->second).c_str()));
	param_seed.set_omega0    (atof((var.find("seed_omega0"    )->second).c_str()));
	param_seed.set_ceo       (atof((var.find("seed_ceo"       )->second).c_str()));
	param_seed.set_offset    (atof((var.find("seed_offset"    )->second).c_str()));
}


void set_dipole(dipole &param_dipole, map <string, string> & var)
{
	param_dipole.set_field (atof((var.find("dipole_field" )->second).c_str()));
	param_dipole.set_length(atof((var.find("dipole_length")->second).c_str()));
	param_dipole.set_nstep (atoi((var.find("dipole_nstep" )->second).c_str()));
	param_dipole.set_type  (atoi((var.find("dipole_type"  )->second).c_str()));
}

void set_undulator(undulator &param_undulator, map <string, string> & var)
{
	param_undulator.set_field (atof((var.find("undulator_field" )->second).c_str()));
	param_undulator.set_period(atof((var.find("undulator_period")->second).c_str()));
	param_undulator.set_nstep (atoi((var.find("undulator_nstep" )->second).c_str()));
	param_undulator.set_num   (atoi((var.find("undulator_num"   )->second).c_str()));
}

void set_filestream(ifstream &infile, ofstream &outfile, map <string, string> & var)
{
	infile.open ((var.find("infilename" )->second).c_str());
	outfile.open((var.find("outfilename")->second).c_str());
}

void check_filestream(ifstream &infile, ofstream &outfile)
{
	if ( !infile || !outfile )
	{
		cout << "File can not open, please check 'infilename' and 'outfilename' in namelist!" << endl;
		exit(1);
	}
}

void unset_filestream(ifstream &infile, ofstream &outfile)
{
	infile.close();
	outfile.close();
}

unsigned int set_whichelement(elementType &param_eletype, dipole &param_dipole, undulator &param_undulator, map <string, string> & var)
{
	string flag = param_eletype.get_flag();
	if(flag == "dipole")
	{
		set_dipole(param_dipole, var);
		return 0;
	}
	else if(flag == "undulator")
	{
		set_undulator(param_undulator, var);
		return 1;
	}
	else
	{
		cout << "Please specify the 'use_element' in namelist file explicitly!" << endl;
		exit(1);
	} 
}

void printallvar(unsigned int flag, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator)
{
	param_seed.printall();
	if(flag == 0)
		param_dipole.printall();
	else if(flag == 1)
		param_undulator.printall();
	else
	{
		cout << "Unexpected flag, ERROR!\n";
		exit(1);
	}
}

void refresh_var(std::string vname, double value, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, map <string, string> & var)
{
	var.find(vname)->second = dbl2str(value);
	set_seedlaser(param_seed     , var);
	set_dipole   (param_dipole   , var);
	set_undulator(param_undulator, var);
}

std::string dbl2str(double &x)
{
	stringstream sstr;
	sstr << x;
	return sstr.str();
}
