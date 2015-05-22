/*********************************************************************\
 * Program: manibeam
 * Purpose: manipulate beam by matrice                               *  
 * Copyright (C) 2014 Tong Zhang                                     *
 *                                                                   *
 * This program is free software: you can distribute it and/or modify*
 * it under the terms of GNU General Public License as published by  *
 * the Free Software Foundation, either version 3 of the License or  *
 * (at your option) any later version.                               *
 *                                                                   *
 * This program is distributed in the hope that it will be useful,   *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of    *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      *
 * GNU General Public License for more details.                      *
 *                                                                   *
 * You should have received a copy of the GNU General Public License *
 * along with this program. If not, see <http://www.gnu.org/licenses/>*
\*********************************************************************/

/****************************************************************************\
This program is written for manipulating x,xp,y,yp of particle beam file.

Uasge: manibeam old_dpafile new_dpafile total_slices mx11 mx12 mx21 mx22 my11 my12 my21 my22

Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: 10:54, Oct. 31, 2014
\****************************************************************************/

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <vector>

using namespace std;

int main(int argc, char **argv)
{
	if(argc != 12)
	{
		if(argc > 1)cout << "Not enough parameters!\n";
		cout << "Usage: " << argv[0] << " file1 file2 total_slice MX(4) MY(4)\n";
		cout << "\t" << "file1: " << "\t\t" << "dpa file to be manipulated\n";
		cout << "\t" << "file2: " << "\t\t" << "dpa file after manipulated\n";
		cout << "\t" << "total_slice: " << "\t" << "total slice number of dpa file\n";
		cout << "\t" << "MX(4):" << "\t" << "mx11,mx12,mx21,mx22\n";
		cout << "\t" << "MY(4):" << "\t" << "my11,my12,my21,my22\n\n";
		exit(1);
	}

	string file1    = argv[1];  // dpa file name to read, old dpa file
	string file2    = argv[2];  // phase-shifted dpa file name to write in
	unsigned int total_slices= atoi(argv[3]); // total slice number of dpa file

    double mx11 = atof(argv[4]);
    double mx12 = atof(argv[5]);
    double mx21 = atof(argv[6]);
    double mx22 = atof(argv[7]);

    double my11 = atof(argv[8]);
    double my12 = atof(argv[9]);
    double my21 = atof(argv[10]);
    double my22 = atof(argv[11]);

	fstream oldfile(file1.c_str(), ios::in  | ios::binary);
	fstream newfile(file2.c_str(), ios::out | ios::binary);


	if (!oldfile || !newfile) 	// if any one of files cannot open, return error, exit
	{
		cout << "Open file error!\n\n";
		exit(1);
	}

	// read oldfile into vector a
	vector <double> a; 
	double temp;
	unsigned int data_count=0;
	oldfile.read((char*)&temp, sizeof(double));
	do
	{
		a.push_back(temp);
		oldfile.read((char*)&temp, sizeof(double));
		data_count++;
	}while(!oldfile.eof());
	oldfile.close();
//	cout << data_count << " data read.\n";

	unsigned int npart = data_count/6/total_slices; // total particle number
	//
	//write modified data into newfile
	
    double g0, x0, y0, xp0, yp0;
    double x, y, xp, yp;
	for(unsigned int i=0; i<total_slices; i++)
	{
        // [(6i+0)n, (6i+1)n): gamma;
        // [(6i+1)n, (6i+2)n): theta;
        // [(6i+2)n, (6i+3)n): x;
        // [(6i+3)n, (6i+4)n): y;
        // [(6i+4)n, (6i+5)n): px(=xp*gamma)
        // [(6i+5)n, (6i+6)n): py(=yp*gamma);
		for(unsigned int j=0; j<npart; j++)
        {
            g0  = a[(6*i+0)*npart+j];
            x0  = a[(6*i+2)*npart+j];
            y0  = a[(6*i+3)*npart+j];
            xp0 = a[(6*i+4)*npart+j]/g0;
            yp0 = a[(6*i+5)*npart+j]/g0;
			x  = mx11*x0 + mx12*xp0;
            xp = mx21*x0 + mx22*xp0;
			y  = my11*y0 + my12*yp0;
            yp = my21*y0 + my22*yp0;
            a[(6*i+2)*npart+j] = x;
            a[(6*i+3)*npart+j] = y;
            a[(6*i+4)*npart+j] = xp*g0;
            a[(6*i+5)*npart+j] = yp*g0;
        }
	}

	for(unsigned int i=0; i<data_count; i++)
		newfile.write((char*)&(a[i]), sizeof(double));
	
	oldfile.close();
	newfile.close();

	return 0;
}

