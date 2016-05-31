#include <fstream>
#include <cmath>
#include <string>
#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <map>
#include "interaction.h"
#include "readinput.h"
#include "element.h"

double func_mean(double *a, int size)
{
    double s=0;
    for(int i=0; i<size; i++)s+=*(a+i);
    return s/double(size);
}

void readdata(std::ifstream &infile, elementType &param_eletype, double* &s0, double* &gam0, double* &x0, double* &y0, double* &vx0, double* &vy0)
{
	unsigned int npart = param_eletype.get_npart();
	double *ptrs0   = new double[npart];
	double *ptrgam0 = new double[npart];
	double *ptrx0   = new double[npart];
	double *ptry0   = new double[npart];
	double *ptrvx0  = new double[npart];
	double *ptrvy0  = new double[npart];
	for(unsigned int i = 0; i< npart; i++)
	{
		infile >> ptrs0[i]; ptrs0[i]*=C0;
		infile >> ptrgam0[i];
		infile >> ptrx0[i];
		infile >> ptry0[i];
		infile >> ptrvx0[i]; ptrvx0[i]*=C0;
		infile >> ptrvy0[i]; ptrvy0[i]*=C0;
	}
	infile.close();
	s0   = ptrs0;
	gam0 = ptrgam0;
	x0   = ptrx0;
	y0   = ptry0;
	vx0  = ptrvx0;
	vy0  = ptrvy0;
}

double interactDump(std::ofstream &outfile, elementType &param_eletype, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, unsigned int flag, double *s0, double *gam0, double *x0, double *y0, double *vx0, double *vy0)
{
	unsigned int npart = param_eletype.get_npart();
	double zc = func_mean(s0, npart);
	double z0, gam, x, y, vx, vy, vz, z, dt, Ex, ax, az;
    double sum_gsq = 0, sum_g = 0;
	if(flag == 0)//dipole
	{
		unsigned int    nstep = param_dipole.get_nstep ();
		bool 		    dtype = param_dipole.get_type  ();
		double 		       By = param_dipole.get_field ();
		double  dipole_length = param_dipole.get_length();
		double radius, theta, phi, delphi, vtan;
		for(unsigned int i = 0; i< npart; i++)
		{
			z0  = s0[i];
			gam = gam0[i];
			x   = x0[i];
			y   = y0[i];
			vx  = vx0[i];
			vy  = vy0[i];
			vz  = sqrt(1.0-1.0/gam/gam-(vx*vx+vy*vy)/C0/C0)*C0;
			radius = gam*M0*C0/By/E0;
			theta  = asin(dipole_length/(2.0-dtype)/radius)*(2.0-dtype);
			phi    = (dtype-1)*theta/2.0;
			delphi = theta/nstep;
			vx     = vz*sin(phi)+vx;
			vz     = vz*cos(phi);
			dt     = radius*theta/C0/nstep;
			z      = 0;
			for(unsigned int j = 0; j < nstep; j ++)
			{
				Ex   = param_seed.get_ElectricalFieldIntensityz(z0,zc,x,y);
				ax   = E0/gam/M0*(-vz*By);
				az   = E0/gam/M0*(vx*By);
				x   += (vx+0.5*ax*dt)*dt;
				y   += vy*dt;
				z   += (vz+0.5*az*dt)*dt;
				z0  += (vz+0.5*az*dt-C0)*dt;
				gam += E0*Ex*vx*dt/M0/C0/C0;
				vtan = sqrt(1.0-1.0/gam/gam-vy*vy/C0/C0)*C0;
				phi += delphi;
				vx   = vtan*sin(phi);
				vz   = vtan*cos(phi);
			}
			outfile << std::scientific;
			outfile.precision(18);
			outfile << z0/C0 << "\t" << gam << "\t" << x << "\t" << y << "\t" << vx/C0 << "\t" << vy/C0 << "\n" ;
			sum_gsq += gam*gam;
			sum_g   += gam;
		}
		outfile.close();
	}
	else if(flag == 1)//undulator
	{
		unsigned int      nstep = param_undulator.get_nstep ();
		unsigned int         Nu = param_undulator.get_num   ();
		double               B0 = param_undulator.get_field ();
		double undulator_period = param_undulator.get_period();
		double By, ku = 2.0*PI/undulator_period;
		dt = undulator_period/C0/nstep;
		for(unsigned int i = 0; i< npart; i++)
		{
			z0  = s0[i];
			gam = gam0[i];
			x   = x0[i];
			y   = y0[i];
			vx  = vx0[i];
			vy  = vy0[i];
			vz  = sqrt(1.0-1.0/gam/gam-(vx*vx+vy*vy)/C0/C0)*C0;
			z   = 0;
			for(unsigned int j = 0; j < nstep*Nu; j ++)
			{
				By   = B0*sin(ku*z+PI/2);
				Ex   = param_seed.get_ElectricalFieldIntensityz(z0,zc,x,y);
				ax   = E0/gam/M0*(-vz*By);
				az   = E0/gam/M0*(vx*By);
				x   += (vx+0.5*ax*dt)*dt;
				y   += (vy*dt);
				z   += (vz+0.5*az*dt)*dt;
				z0  += (vz+0.5*az*dt-C0)*dt;
				gam += (E0*Ex*vx*dt/M0/C0/C0);
				vx  += (ax*dt);
				vz   = sqrt(1.0-1.0/gam/gam-(vx*vx+vy*vy)/C0/C0)*C0;
			}
			outfile.precision(16);
			outfile << z0/C0 << "\t" << gam << "\t" << x << "\t" << y << "\t" << vx/C0 << "\t" << vy/C0 << "\n" ;
			sum_gsq += (gam*gam);
			sum_g   += gam;
		}
		outfile.close();
	}
	return sqrt(sum_gsq/npart-sum_g*sum_g/npart/npart);
}

double interactNotDump(elementType &param_eletype, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, unsigned int flag, double *s0, double *gam0, double *x0, double *y0, double *vx0, double *vy0)
{
	unsigned int npart = param_eletype.get_npart();
	double zc = func_mean(s0, npart);
	double z0, gam, x, y, vx, vy, vz, z, dt, Ex, ax, az;
    double sum_gsq = 0, sum_g = 0;
	if(flag == 0)//dipole
	{
		unsigned int    nstep = param_dipole.get_nstep ();
		bool 		    dtype = param_dipole.get_type  ();
		double 		       By = param_dipole.get_field ();
		double  dipole_length = param_dipole.get_length();
		double radius, theta, phi, delphi, vtan;
		for(unsigned int i = 0; i< npart; i++)
		{
			z0  = s0[i];
			gam = gam0[i];
			x   = x0[i];
			y   = y0[i];
			vx  = vx0[i];
			vy  = vy0[i];
			vz  = sqrt(1.0-1.0/gam/gam-(vx*vx+vy*vy)/C0/C0)*C0;
			radius = gam*M0*C0/By/E0;
			theta  = asin(dipole_length/(2.0-dtype)/radius)*(2.0-dtype);
			phi    = (dtype-1)*theta/2.0;
			delphi = theta/nstep;
			vx     = vz*sin(phi)+vx;
			vz     = vz*cos(phi);
			dt     = radius*theta/C0/nstep;
			z      = 0;
			for(unsigned int j = 0; j < nstep; j ++)
			{
				Ex   = param_seed.get_ElectricalFieldIntensityz(z0,zc,x,y);
				ax   = E0/gam/M0*(-vz*By);
				az   = E0/gam/M0*(vx*By);
				x   += (vx+0.5*ax*dt)*dt;
				y   += (vy*dt);
				z   += (vz+0.5*az*dt)*dt;
				z0  += (vz+0.5*az*dt-C0)*dt;
				gam += E0*Ex*vx*dt/M0/C0/C0;
				vtan = sqrt(1.0-1.0/gam/gam-vy*vy/C0/C0)*C0;
				phi += delphi;
				vx   = vtan*sin(phi);
				vz   = vtan*cos(phi);
			}
			sum_gsq += gam*gam;
			sum_g   += gam;
		}
	}
	else if(flag == 1)//undulator
	{
		unsigned int      nstep = param_undulator.get_nstep ();
		unsigned int         Nu = param_undulator.get_num   ();
		double               B0 = param_undulator.get_field ();
		double undulator_period = param_undulator.get_period();
		double By, ku = 2.0*PI/undulator_period;
		dt = undulator_period/C0/nstep;
		for(unsigned int i = 0; i< npart; i++)
		{
			z0  = s0[i];
			gam = gam0[i];
			x   = x0[i];
			y   = y0[i];
			vx  = vx0[i];
			vy  = vy0[i];
			vz  = sqrt(1.0-1.0/gam/gam-(vx*vx+vy*vy)/C0/C0)*C0;
			z   = 0;
			for(unsigned int j = 0; j < nstep*Nu; j ++)
			{
				By   = B0*sin(ku*z+PI/2);
				Ex   = param_seed.get_ElectricalFieldIntensityz(z0,zc,x,y);
				ax   = E0/gam/M0*(-vz*By);
				az   = E0/gam/M0*(vx*By);
				x   += (vx+0.5*ax*dt)*dt;
				y   += vy*dt;
				z   += (vz+0.5*az*dt)*dt;
				z0  += (vz+0.5*az*dt-C0)*dt;
				gam += E0*Ex*vx*dt/M0/C0/C0;
				vx  += ax*dt;
				vz   = sqrt(1.0-1.0/gam/gam-(vx*vx+vy*vy)/C0/C0)*C0;
			}
			sum_gsq += gam*gam;
			sum_g   += gam;
		}
	}
	return sqrt(sum_gsq/npart-sum_g*sum_g/npart/npart);
}

void performScan(std::ofstream &outfile, scanPanel &param_scan, elementType &param_eletype, seedlaser &param_seed, dipole &param_dipole, undulator &param_undulator, std::map <std::string, std::string> &var, unsigned int flag, double *s0, double *gam0, double *x0, double *y0, double *vx0, double *vy0)
{
	std::string scanparam = param_scan.get_sparam();
	double      scanbegin = param_scan.get_sbegin();
	double      scanstep  = param_scan.get_sstep ();
	double      scanend   = param_scan.get_send  ();
	int 		scanecho  = param_scan.get_secho ();
	double rms_delg; //modulation amplititude, rms
	check_scansetup(scanparam, scanbegin, scanstep, scanend);
	for(double vscan = scanbegin;vscan <= scanend;vscan += scanstep)
	{
		if(scanecho)
		{
			std::cout << std::setw(10) << scanparam << " = " << std::setw(10) << vscan << "\n";
		}
		refresh_var(scanparam, vscan, param_seed, param_dipole, param_undulator, var);
		rms_delg = interactNotDump(param_eletype, param_seed, param_dipole, param_undulator, flag, s0, gam0, x0, y0, vx0, vy0);
		outfile << std::setw(10) << vscan << std::setw(20) << std::setprecision(16) << rms_delg << "\n";
	}
	outfile.close();
}

void check_scansetup(std::string scanparam, double scanbegin, double scanstep, double scanend)
{
	
	if(!check_scanparam(scanparam))
	{
		std::cout << "Scan parameter name setting error!\n";
		exit(1);
	}

	if(scanstep<0 || scanend < scanbegin)
	{
		std::cout << "Scan range setup error!\n";
		exit(1);
	}
}

int check_scanparam(std::string scanparam)
{
	int ifind = 0;
	std::string AllScanParam[11] = {"seed_wavelength",
							  		"seed_power",
							  		"seed_tau",
							  		"seed_ceo",
							 		"seed_omega0",
								 	"seed_offset",
							 		"dipole_field",
								    "dipole_length",
							 	    "undulator_period",
							 	    "undulator_field",
							 	    "undulator_num"};

	for(int i=0;i<11;i++)
	{
		if(AllScanParam[i]==scanparam)ifind = 1;
	}

	return ifind;
}
