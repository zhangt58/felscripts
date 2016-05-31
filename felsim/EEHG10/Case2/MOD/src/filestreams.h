#ifndef _FILESTREAMS_H
#define _FILESTREAMS_H

#include <string>
#include <fstream>

class in_file_stream
{
	private:
		std::ifstream sfile;
		std::ifstream filename;
		unsigned int npart;
		unsigned int size;
		double *data;
	public:
		void set_filestream(std::string);
		void unset_filestream();
		void set_npart(unsigned int n);
		void printall();
		void readdata();
		void printdata();
		std::string get_filename();
		unsigned int get_npart();
}

#endif
