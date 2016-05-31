#include "element.h"
#include <cmath>
#include <iostream>
#include <iomanip>
#include <string>

const double Z0 = sqrt(mu0/eps0);     // ~377

/*************************************************************************************\
\*************************************************************************************/

//element overview
void elementType::set_flag(std::string str)
{
	flag = str;
}

void elementType::set_print(bool flag)
{
	print_list = flag;
}

void elementType::set_npart(unsigned int n)
{
	npart = n;
}

unsigned elementType::get_npart()
{
	return npart;
}

std::string elementType::get_flag()
{
	return flag;
}

bool elementType::get_print()
{
	return print_list;
}

void elementType::printall()
{
	std::cout << std::left;
	std::cout << "------------------------------\n";
	std::cout << "elementType:\n";
	std::cout << std::setw(16) << "element type: "   << std::setw(12) << flag << "\n";
	std::cout << std::setw(16) << "total particle: " << std::setw(12) << npart << std::endl;
	std::cout << "------------------------------\n\n";
}

/*************************************************************************************\
\*************************************************************************************/

//scanPanel
void scanPanel::set_sflag(bool flag)
{
	scan_flag = flag;
}

void scanPanel::set_secho(bool flag)
{
	scan_echo = flag;
}

void scanPanel::set_sparam(std::string str)
{
	scan_param = str;
}

void scanPanel::set_sbegin(double x)
{
	scan_begin = x;
}

void scanPanel::set_sstep(double x)
{
	scan_step = x;
}

void scanPanel::set_send(double x)
{
	scan_end = x;
}

bool scanPanel::get_sflag()
{
	return scan_flag;
}

bool scanPanel::get_secho()
{
	return scan_echo;
}

std::string scanPanel::get_sparam()
{
	return scan_param;
}

double scanPanel::get_sbegin()
{
	return scan_begin;
}

double scanPanel::get_sstep()
{
	return scan_step;
}

double scanPanel::get_send()
{
	return scan_end;
}

void scanPanel::printall()
{
	std::cout << std::left;
	std::cout << "------------------------------\n";
	std::cout << "scanPanel:\n";
	std::cout << std::setw(16) << "scan_flag: " << std::setw(12) << scan_flag << "\n";
	if(scan_flag)
	{
		std::cout << std::setw(16) << "scan_param: " << std::setw(12) << scan_param << "\n";
		std::cout << std::setw(16) << "scan_begin"   << std::setw(12) << scan_begin << "\n";
		std::cout << std::setw(16) << "scan_step"    << std::setw(12) << scan_step  << "\n";
		std::cout << std::setw(16) << "scan_end"     << std::setw(12) << scan_end   << "\n";
		std::cout << std::setw(16) << "scan_echo: "  << std::setw(12) << scan_echo  << std::endl;
	}
	std::cout << "------------------------------\n\n";
}

/*************************************************************************************\
\*************************************************************************************/

//seedlaser
void seedlaser::set_wavelength(double x)
{
	seed_wavelength = x; // [meter]
}

void seedlaser::set_peakpower(double x)
{
	seed_power = x; // [watt]
}

void seedlaser::set_tau(double x)
{
	seed_tau = x; // FWHM, [sec]
	seed_sigmaz = x*C0/(2.0*sqrt(2.0*log(2.0))); // rms, [meter]
}

void seedlaser::set_ceo(double x)
{
	seed_ceo = x/PI*180; // [rad], x: [deg]
}

void seedlaser::set_omega0(double x)
{
	seed_omega0 = x; // [meter]
}

void seedlaser::set_offset(double x)
{
	seed_offset = x*seed_wavelength; // [meter], x: in unit of seed_wavelength
}

double seedlaser::get_wavelength()
{
	return seed_wavelength; // [meter]
}

double seedlaser::get_peakpower()
{
	return seed_power; // [watt]
}

double seedlaser::get_tau()
{
	return seed_tau; // FWHM, [sec]
}

double seedlaser::get_sigmaz()
{ 
	return seed_sigmaz; //rms, [meter]
}

double seedlaser::get_ceo()
{
	return seed_ceo; // [rad]
}

double seedlaser::get_omega0()
{
	return seed_omega0; // [meter]
}

double seedlaser::get_offset()
{
	return seed_offset; // [meter], x: in unit of seed_wavelength
}

double seedlaser::get_ElectricalFieldIntensity0()
{
	return sqrt(4.0*Z0*seed_power/PI/seed_omega0/seed_omega0);
}

double seedlaser::get_EnvelopeAmplitude(double z, double zc)
{
	return exp(-(z-(zc+seed_offset))*(z-(zc+seed_offset))/2.0/seed_sigmaz/seed_sigmaz);
}

double seedlaser::get_ElectricalFieldIntensityz(double z, double zc, double x, double y)
{
	double I0 = get_EnvelopeAmplitude(z,zc); 
	return sqrt(4.0*Z0*seed_power/PI/seed_omega0/seed_omega0)*sqrt(I0)*cos((z-(zc+seed_offset))*2.0*PI/seed_wavelength+seed_ceo)*exp(-1.0/2.0*(x*x+y*y)/seed_omega0/seed_omega0);
}

void seedlaser::printall()
{
	std::cout << std::left;
	std::cout << "------------------------------\n";
	std::cout << "seedlaser:\n";
	std::cout << std::setw(16) << "wavelength: "     << std::setw(10) << seed_wavelength << " [nm]\n";
	std::cout << std::setw(16) << "peak power: "     << std::setw(10) << seed_power      << " [W]\n";
	std::cout << std::setw(16) << "pulse width[t]: " << std::setw(10) << seed_tau        << " [sec](FWHM)\n";
	std::cout << std::setw(16) << "pulse width[z]: " << std::setw(10) << seed_sigmaz     << " [m](rms)\n";
	std::cout << std::setw(16) << "waist size: "     << std::setw(10) << seed_omega0     << " [m]\n";
	std::cout << std::setw(16) << "offset: "         << std::setw(10) << seed_offset     << " [m]\n";
	std::cout << std::setw(16) << "CEO: "  	         << std::setw(10) << seed_ceo        << " [rad]" << std::endl;
	std::cout << "------------------------------\n\n";
}

/*************************************************************************************\
\*************************************************************************************/

//dipole
void dipole::set_field(double x)
{
	dipole_field = x; // [tesla]
}

void dipole::set_length(double x)
{
	dipole_length = x; // [meter]
}

void dipole::set_nstep(unsigned int n)
{
	dipole_nstep = n;
}

void dipole::set_type(bool flag)
{
	dipole_type = flag; // full dipole flag =0, otherwise, =1
}

double dipole::get_field()
{
	return dipole_field; // [tesla]
}

double dipole::get_length()
{
	return dipole_length; // [meter]
}

unsigned int dipole::get_nstep()
{
	return dipole_nstep;
}

bool dipole::get_type()
{
	return dipole_type; // full dipole flag =0, otherwise, =1
}

void dipole::printall()
{
	std::cout << std::left;
	std::cout << "------------------------------\n";
	std::cout << "dipole:\n";
	std::cout << std::setw(16) << "field strength: " << std::setw(10) << dipole_field  << " [T]\n";
	std::cout << std::setw(16) << "length: " 	 	 << std::setw(10) << dipole_length << " [m]\n";
	std::cout << std::setw(16) << "nstep: " 		 << std::setw(10) << dipole_nstep  << "\n";
	std::cout << std::setw(16) << "type: " 		     << std::setw(10) << dipole_type 	 << std::endl;
	std::cout << "------------------------------\n\n";
}

/*************************************************************************************\
\*************************************************************************************/

//undulator
void undulator::set_field(double x)
{
	undulator_field = x; // undulator peak field, [tesla]
}

void undulator::set_period(double x)
{
	undulator_period = x; // [meter]
}

void undulator::set_num(unsigned int n)
{
	undulator_num = n; // total undulator period
}

void undulator::set_nstep(unsigned int n)
{
	undulator_nstep = n; // nstep per period
}


double undulator::get_field()
{
	return undulator_field; // undulator peak field, [tesla]
}

double undulator::get_period()
{
	return undulator_period; // [meter]
}

unsigned int undulator::get_num()
{
	return undulator_num; // total undulator period
}

unsigned int undulator::get_nstep()
{
	return undulator_nstep; // nstep per period
}

void undulator::printall()
{
	std::cout << std::left;
	std::cout << "------------------------------\n";
	std::cout << "undulator:\n";
	std::cout << std::setw(16) << "field strength: " << std::setw(10) << undulator_field  << " [T]\n";
	std::cout << std::setw(16) << "period: " 		 << std::setw(10) << undulator_period << " [m]\n";
	std::cout << std::setw(16) << "Nu: " 		     << std::setw(10) << undulator_num    << "\n";
	std::cout << std::setw(16) << "nstep: " 		 << std::setw(10) << undulator_nstep  << std::endl;
	std::cout << "------------------------------\n\n";
}

/*************************************************************************************\
\*************************************************************************************/
