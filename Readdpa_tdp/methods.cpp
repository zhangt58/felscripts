#include "methods.h"
#include <algorithm>
#include <cmath>

void post_process::set_data(double *x)
{
	data = x;
}

void post_process::set_dataSize(unsigned n)
{
	data_size = n;
}

void post_process::set_nbins(unsigned n)
{
	nbins = n;
}

void post_process::set_pCharge(double x)
{
	pCharge = x;
}

double *post_process::get_data()
{
	return data;
}

unsigned int post_process::get_dataSize()
{
	return data_size;
}

unsigned int post_process::get_nbins()
{
	return nbins;
}

double post_process::get_pCharge()
{
	return pCharge;
}

double post_process::get_binWidth()
{
	return bin_width;
}

void post_process::histc()
{
	//sort data by default compare function (i<j)
	std::sort(data, data+data_size);
	data_max  = data[data_size-1];
	data_min  = data[0];
	bin_width = (data_max-data_min)/(double)nbins;

	double *count_bins = new double [nbins];
	double *x1_bins    = new double [nbins];
	double *x2_bins    = new double [nbins];

	double level_bins_low, level_bins_up;
	level_bins_low = data_min;
	unsigned int i = 0, j = 0, count_n;
	while (i < nbins)
	{
		count_n = 0;
		level_bins_up = level_bins_low + bin_width;
		while (j < data_size && data[j] < level_bins_up){count_n++;++j;};
		count_bins[i] = count_n;
		x1_bins   [i] = level_bins_low;
		x2_bins   [i] = level_bins_up;
		level_bins_low  = level_bins_up;
		++i;
	}
	histc_data_y  = count_bins;
	histc_data_x1 = x1_bins;
	histc_data_x2 = x2_bins;
}

double *post_process::get_histc_x1()
{
	return histc_data_x1;
}

double *post_process::get_histc_x2()
{
	return histc_data_x2;
}

double *post_process::get_histc_y()
{
	return histc_data_y;
}

double post_process::get_peakCurrent()
{
	histc(); 	// histc data, store histc data in histc_data_xy
	double peak_current = 0, current_i;
	for(unsigned int i = 0;i< nbins; i++)
	{
		current_i = histc_data_y[i]*pCharge/data_size/bin_width;
		if(current_i > peak_current)peak_current = current_i;
	}
	return peak_current;
}

double post_process::get_bunching(int n, double wavelength) // calculate b[n]
{
	double sum_r =0, sum_i = 0, nck = n*C0*2*PI/wavelength;
	for(unsigned int i = 0;i < data_size; i++)
	{
		sum_r += cos(nck*data[i]);
		sum_i += sin(nck*data[i]);
	}
	return sqrt(sum_r*sum_r+sum_i*sum_i)/data_size;
}
