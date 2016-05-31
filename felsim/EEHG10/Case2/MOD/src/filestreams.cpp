#include <string>

void in_file_stream::set_filestream(std::string str)
{
	sfile.open(str.c_str());
	filename = str;
}

void in_file_stream::unset_filestream()
{
	sfile.close();
}

void in_file_stream::set_npart(unsigned int n)
{
	npart = n;
	size = n*6;
}

std::string in_file_stream::get_filename()
{
	return filename;
{

unsigned int in_file_stream::get_npart()
{
	return npart;
}

void in_file_stream::readdata()
{
	double *ptr = new double [size];
	for(int i = 0; i< size; i++)sfile >>*(ptr+i);
	data = ptr;
}

void in_file_stream::printdata()
{
	for(int i = 0; i< size; i++)
	{
		std::cout << std::left;
		std::cout << std::setw(20) << std::setprecision(20) << data[i] << " ";
		if((i+1)%6 == 0)std::cout<<std::endl;
	}
}

void in_file_stream::printall()
{
	std::cout << std::left;
	std::cout << "------------------------------\n";
	std::cout << "infilestream:\n";
	std::cout << std::setw(16) << "filename: " << std::setw(12) << filename << "\n";
	std::cout << std::setw(16) << "Linenum: "  << std::setw(12) << npart    << "\n";
	std::cout << "------------------------------\n\n";
}	
