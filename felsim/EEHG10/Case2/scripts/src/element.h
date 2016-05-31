#ifndef ELEMENT_H
#define ELEMENT_H
#include <string>
//constants
const double PI   = 3.141592653589793;
const double eps0 = 8.854187817620e-12; // vacuum permittivity, [F/m]
const double mu0  = 4*PI*1e-7;          // vacuum permeability, [V.s/(A.m)]
const double M0   = 9.10938188E-31;     // electron mass, [kg]
const double E0   = 1.60218E-19;        // electron charge, [coulomb]
const double C0   = 299792458.0;        // light speed, [meter/sec]

class elementType
{
	private:
		std::string flag; 				// use_element value
		bool print_list;
		unsigned int npart; 			// inputfile size, particle number
	public:
		void set_flag(std::string str);
		void set_npart(unsigned int n);
		void set_print(bool flag);
		bool get_print();
		unsigned int get_npart();
		std::string get_flag();
		void printall(); 				// print all private infomation
};

class scanPanel
{
	private:
		bool scan_flag; 				// scan_flag = 1, do scan parameter, or not
		bool scan_echo; 				// scan_echo = 1, print scanning result to stdout, otherwise, do not print
		std::string scan_param; 		// specify the parameter name to scan
		double scan_begin, scan_step, scan_end; // specify the scan range, beginning ,step and ending
	public:
		void set_sflag(bool flag);
		void set_secho(bool flag);
		void set_sparam(std::string str);
		void set_sbegin(double x);
		void set_sstep(double x);
		void set_send(double x);

		bool get_sflag();
		bool get_secho();
		std::string get_sparam();
		double get_sbegin();
		double get_sstep();
		double get_send();
		void printall();
};

class seedlaser
{
	private:
		double seed_wavelength, seed_power, seed_tau, seed_sigmaz,
			   seed_ceo,seed_omega0, seed_offset;
	public:
		void set_wavelength(double x); //x: [meter]
		void set_peakpower (double x); //x: [watt]
		void set_tau       (double x); //x: [sec]
		void set_ceo       (double x); //x: [deg]
		void set_omega0    (double x); //x: [meter] 
		void set_offset    (double x); //x: [seed_wavelength]
		
		double get_wavelength(); 
		double get_peakpower (); 
		double get_tau       (); 
		double get_sigmaz    (); 
		double get_ceo       (); 
		double get_omega0    (); 
		double get_offset    (); 
		
		double get_ElectricalFieldIntensity0(); //Ex0
		double get_ElectricalFieldIntensityz(double z, double zc, double x, double y); //z: in-bunch pos, zc: central pos of bunch, x, y: transverse pos 
		double get_EnvelopeAmplitude(double z, double zc);

		void printall(); 				// print all private infomation
};

class dipole
{
	private:
		double dipole_field, dipole_length;
		unsigned int dipole_nstep;
		bool dipole_type;
	public:
		void set_field (double x); //x: [tesla]
		void set_length(double x); //x: [meter]
		void set_nstep (unsigned int n);
		void set_type  (bool flag); // full dipole flag =0, otherwise, =1
		
		double get_field (); 		// [tesla]
		double get_length(); 		// [meter]
		unsigned int get_nstep ();
		bool get_type(); 			// full dipole flag =0, otherwise, =1

		void printall(); 			// print all private infomation
};

class undulator
{
	private:
		double undulator_period, undulator_field;
		unsigned int undulator_num, undulator_nstep;
	public:
		void set_field (double x); //x: [tesla], undulator peak field
		void set_period(double x); //x: [meter]
		void set_num   (unsigned int n);// total undulator period(<5)
		void set_nstep (unsigned int n);// nstep per period

		double get_field (); 		// [tesla], undulator peak field
		double get_period(); 		// [meter]
		unsigned int get_num  (); 	// total undulator period(<5)
		unsigned int get_nstep(); 	// nstep per period

		void printall(); 			// print all private infomation
};

#endif
