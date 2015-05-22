#!/usr/bin/octave -qf

%--------------------------------------------------------------------------%
% This script is used to extra dfl info from the GENESIS output file by 
% Octve or Matlab
% Author: Tong ZHANG
% Sep. 5th, 2012
%--------------------------------------------------------------------------%

function give_warning()
	printf("Usage: readdfl.m [option] dflfile ascfile ncar\n");
	printf("\t dpafile: filename of the binary dfl file to read\n");
	printf("\t ascfile: filename of the ascii file to write\n");
	printf("\t ncar   : grid size number of the dfl file\n");
	printf("\n");
	printf("Option:\n");
	printf("\t--info\tShow the meanings of each column of the ascfile\n");
end

function give_col_meanings()
	printf("  Columns of ascfile are: realpart imagpart and intensity of the FEL field\n");
	printf("  The size of each columns is ncar*ncar by 1\n");
end

args = argv();

if size(args)(1) == 1 && args{1} == '--info'
	give_col_meanings();
	exit;
end

if size(args)(1) < 3
	give_warning();
	exit;
end


infile  = args{1};          % out.dfl file
outfile = args{2};          % ascii out file
ncar 	= str2num(args{3}); % grid size

% read *.dfl binary files
% grid size ncar*ncar

fid = fopen(infile,'r');
a = fread(fid,'float64');
realpart = a(1:2:end);
imagpart = a(2:2:end);
fldinten = realpart.^2+imagpart.^2;

size(realpart)
size(imagpart)
size(fldinten)

dlmwrite(outfile, [realpart, imagpart, fldinten], 'delimiter', ' ', 'precision', '%18e');


fldinten = reshape(fldinten,ncar,ncar);
%maxinten = max(realpart.^2+imagpart.^2);
%fldinten = fldinten./maxinten;
