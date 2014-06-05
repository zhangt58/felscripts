#ifndef _METHODS_H
#define _METHODS_H

static const double PI = 3.141592653;
static const double C0 = 299792458.0; //[m/s]

class post_process
{
	private:
		unsigned int nbins, data_size;
		double bin_width, data_max, data_min, pCharge;
		double *data;
		double *histc_data_y, *histc_data_x1, *histc_data_x2;
	public:
		void set_data    (double  *x); 	// pass array x to point data
		void set_dataSize(unsigned n); 	// pass size of array x
		void set_nbins   (unsigned n);  // pass bins of histogram
		void set_pCharge (double   x); 	// pass total electron charge, [C]

		double  	*get_data    (); 	// get array data from private set
		unsigned int get_dataSize(); 	// get size of array data
		unsigned int get_nbins   (); 	// get nbins
		double 		 get_pCharge (); 	// get total Charge
		double 		 get_binWidth(); 	// get binwidth, as done histc

		void histc(); // create histogram counts of array data, pass to histc_data_xy
		double *get_histc_x1();  		// get the histed's x1 array,  histc_data_x1 
		double *get_histc_x2(); 		// get the histed's x2 array,  histc_data_x2
		double *get_histc_y (); 		// get the histed count array, histc_data_y

		double get_peakCurrent();  		// calculate the peak current, data: t column of phase space, pCharge: total Charge
		double get_bunching(int n, double wavelength); // calculate b[n]

};
#endif //_METHODS_H
