/*********************************************************************\
 * Program: readdpa and readdpa_lite                                 *
 * Purpose: simulating the phase-shifting when e- pass phase-shifter *  
 * Copyright (C) 2012 Tong Zhang                                     *
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

/**************************************************************************\
  This program is written for read .dpa file(binary) from genesis output file.
Author: Tong ZHANG
e-mail: tzhang@sinap.ac.cn
Created Time: Nov. 10th, 2011
Modified: Sep. 11th, 2012
Usage: readdpa dpafile ascfile
\**************************************************************************/

#include <iostream>
#include <fstream>
#include <cstdlib>
#include <vector>
#include <cmath>
#include <string>

using namespace std;

static const double pi = 3.141592653589793;
static const double c0 = 299792458.0;

template <class T>
T fmod(T f1, T f2)
{
	return f1 - (int)(f1/f2)*f2;
}

double mean(vector<double> a, long param, long powernum)
{
	double sum = 0;
	long npart = a.size()/6, inc_idx = 0, inc_idx1, inc_idx2;
	switch(param)
	{
		case 1: //gamma
			inc_idx = 0;
			break;
		case 2: //theta
			inc_idx = npart;
			break;
		case 3: //x
			inc_idx = npart * 2;
			break;
		case 4: //y
			inc_idx = npart * 3;
			break;
		case 5: //xp
			inc_idx = npart * 4;
			break;
		case 6: //yp
			inc_idx = npart * 5;
			break;
		case 35: //xxp
			inc_idx1 = npart * 2;
			inc_idx2 = npart * 4;
			for (int j = 0; j < npart ; j ++ )
				sum += a[j+inc_idx1]*a[j+inc_idx2]/a[j];
			return sum/(double)npart;
			break;
		case 46: //yyp
			inc_idx1 = npart * 3;
			inc_idx2 = npart * 5;
			for (int j = 0; j < npart ; j ++ )
				sum += a[j+inc_idx1]*a[j+inc_idx2]/a[j];
			return sum/(double)npart;
			break;
	}

	if(powernum == 1)
	{
		if(param == 5 || param == 6)
			for (int j = 0; j < npart ; j ++ )sum += a[j+inc_idx]/a[j];
		else
			for (int j = 0; j < npart ; j ++ )sum += a[j+inc_idx];
	}
	else
	{
		if(param == 5 || param == 6)
			for (int j = 0; j < npart ; j ++ )sum += a[j+inc_idx]*a[j+inc_idx]/a[j]/a[j];
		else
			for (int j = 0; j < npart ; j ++ )sum += a[j+inc_idx]*a[j+inc_idx];
	}

	return sum/(double)npart;

}


void give_usage(char **argv)
{
	cout << "Usage: " << argv[0] << " dpafile ascfile multitimes format\n\n";
	cout << " " << "This program will generate multitimes dpafile to ascfile.\n";
	cout << " " << "e.g. if dpafile contain [0,2pi], then ascfile will range from [0,2pi*N].\n\n";
	cout << " " << "3rd param: data format, elegant or genesis\n\n";
	cout << " " << "Column-name conventions:\n";
	cout << " " << " elegant format:|--t--|gamma|--x--|--y--|betax|betay|\n";
	cout << " " << " genesis format:|gamma|theta|--x--|--y--|--xp-|--yp-|\n";
	cout << " " << " where xp=gamma*betax, yp=gamma*betay, respectively.\n" << endl;
}

void print_bun(int n1, int n2, vector <double> &a, ofstream &fid)
{
	int range = n2 - n1 + 1;
	double *b = new double [range];
	int nharm;
	long npart = a.size()/6;
	for ( int n = 0; n < range ; n ++ )
	{
		nharm = n+n1;
		double sumcos = 0, sumsin = 0;
		for( int j = 0; j < npart; j++)
		{
			sumcos += cos(nharm*a[j+npart]);
			sumsin += sin(-nharm*a[j+npart]);
		}
		b[n] = sqrt(sumcos*sumcos + sumsin*sumsin)/(double)npart;
		fid << nharm << " " << b[n] << "\n";
	}
}


int main(int argc, char**argv)
{
	ifstream infile(argv[1], ios::in | ios::binary); // open dpa file, i.e. input file
	ofstream outfile(argv[2]); // open file for writting

	if (argc == 1)
	{
		give_usage(argv);
		exit(1);
	}

	if (argc < 5)
	{
		cout << "Error! Not enough parameters!\n";
		cout << "Try '"<< argv[0] << "' for more detailed help.\n";
		exit(1);
	}

	if (!infile)
	{
		cout << "Error! Cannot open " << argv[1] << "!\n";
		cout << "Try '"<< argv[0] << "' for more detailed help.\n";
		exit(1);
	}

	if (!outfile)
	{
		cout << "Error! Cannot open " << argv[2] << "!\n";
		cout << "Try '"<< argv[0] << "' for more detailed help.\n";
		exit(1);
	}

	double multitimes = atof(argv[3]);
	string dumformat  = argv[4];
	double temp;
	int i = 0;
	vector <double> a;
	infile.read((char*)&temp,sizeof(double));
	do
	{
		a.push_back(temp);
		infile.read((char*)&temp,sizeof(double));
		i++;
	}while(!infile.eof());
	infile.close();
//	cout << i/6 << " lines read.\n";

	outfile << scientific;
	outfile.precision(18);
	//elegant outfile format: t, gamma, x, y, betax, betay
	//genesis dpafile format: gamma, theta, x,y,xp(gamma*betax),yp(gamma*betay)
	if(dumformat == "genesis")
	{
		for( int npart = i/6, j = 0; j < npart; j ++ )
		{
			for ( int multin = 0; multin < multitimes; multin ++ )
			{	outfile << a[j] 		<< " "	// gamma (Energy, gamma)
						<< fmod(a[j+npart],2*pi)+2*pi*multin 	<< " " 	// theta (particle phase, theta)
						<< a[j+2*npart] << " " 	// x 	 (x position, x)
						<< a[j+3*npart] << " " 	// y 	 (y position, y)
						<< a[j+4*npart] << " " 	// xp 	 (x momenta, normalized to mc, i.e. xp = gamma*betax => betax = xp/gamma)
						<< a[j+5*npart] << "\n";// yp 	 (y momenta, normalized to mc, i.e. yp = gamma*betay => betay = yp/gamma)
			}
		}
	}
	else
	{
/*		if (argc < 6){cout << "Please give xlamds.\n";exit(1);}
		double xlamds = atof(argv[5]);
		for( int npart = i/6, j = 0; j < npart; j ++ )
		{
			for ( int multin = 0; multin < multitimes; multin ++ )
			{	outfile << (fmod(a[j+npart],2*pi)+2*pi*multin)*xlamds/2/pi/c0 	<< " " 	// theta (particle phase, theta)
						<< a[j] 			<< " "	// gamma (Energy, gamma)
						<< a[j+2*npart] 	<< " " 	// x 	 (x position, x)
						<< a[j+3*npart] 	<< " " 	// y 	 (y position, y)
						<< a[j+4*npart]/a[j] << " " 	// xp 	 (x momenta, normalized to mc, i.e. xp = gamma*betax => betax = xp/gamma)
						<< a[j+5*npart]/a[j] << "\n";// yp 	 (y momenta, normalized to mc, i.e. yp = gamma*betay => betay = yp/gamma)
			}
		}
	*/
	}



	outfile.close();


////////////////////////////////////////////////////////////////////////////
	//parameters can be calculated from imported data(a[i])
/*	double emitx, sigmax, sigmaxp, //betax, alphax, gammax,
		   emity, sigmay, sigmayp, //betay, alphay, gammay,
		   avggam, avgx2, avgy2, avgxp2, avgyp2, avgxxp, avgyyp;
	
	avggam = mean(a,1,1);
	avgx2  = mean(a,3,2);
	avgxp2 = mean(a,5,2);
	avgy2  = mean(a,4,2);
	avgyp2 = mean(a,6,2);
	avgxxp = mean(a,35,1);
	avgyyp = mean(a,46,1);

	emitx = sqrt(avgx2*avgxp2-avgxxp*avgxxp);
	emity = sqrt(avgy2*avgyp2-avgyyp*avgyyp);
	sigmax  = sqrt(avgx2);
	sigmaxp = sqrt(avgxp2);
	sigmay  = sqrt(avgy2);
	sigmayp = sqrt(avgyp2);
*/
//dump bunching info


	string tmp = argv[5];
	ofstream bunfile(tmp.c_str());
	int nharm_min = atoi(argv[6]);
	int nharm_max = atoi(argv[7]);
/*
	cout << argv[1] 	<< "\n";
	cout << argv[2] 	<< "\n";
	cout << multitimes 	<< "\n";
	cout << dumformat 	<< "\n";
	cout << argv[5] 	<< "\n";
	cout << nharm_min 	<< "\n";
	cout << nharm_max	<< "\n";
*/
	print_bun(nharm_min, nharm_max, a, bunfile);

/*
	cout << scientific << left;
	cout.precision(6);
	cout << "------------------------------\n"
		 << "Normalized emittance: \n"
		 << " Emitnx = " << emitx * avggam << " m.rad\n"
		 << " Emitny = " << emity * avggam << " m.rad\n"
		 << "------------------------------\n"
		 << "RMS Beam Size: "  		  << "\n"
		 << " sigmax  = "  << sigmax  << "\n"
		 << " sigmax' = "  << sigmaxp << "\n"
		 << " sigmay  = "  << sigmay  << "\n"
		 << " sigmay' = "  << sigmayp << "\n"
		 << "------------------------------\n"
		 << "Bunching factor: \n"
		 << " b1 | " << b[0] << " | " << " b5 | " << b[4] << " |\n"  
		 << " b2 | " << b[1] << " | " << " b6 | " << b[5] << " |\n"  
		 << " b3 | " << b[2] << " | " << " b7 | " << b[6] << " |\n"  
		 << " b4 | " << b[3] << " | " << " b8 | " << b[7] << " |\n"  
		 << "See more detailed bunching factor in the file bun.tmp\n"
		 << "------------------------------\n"
		 << "Twiss Parameters: \n"
		 << " betax  = " << sigmax*sigmax/emitx   << "\n"
		 << " gammax = " << sigmaxp*sigmaxp/emitx << "\n"
		 << " alphax = " << -avgxxp/emitx 		  << "\n"
		 << " betay  = " << sigmay*sigmay/emity   << "\n"
		 << " gammay = " << sigmayp*sigmayp/emity << "\n"
		 << " alphay = " << -avgyyp/emity 		  << endl;
*/
	return 0;
}
