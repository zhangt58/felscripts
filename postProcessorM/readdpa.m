%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program: readdpa.m                                                 %
% Purpose: extract slices from dpa file from GENESIS 1.3             %  
% Copyright (C) 2012 Tong Zhang                                      %
%                                                                    %
%                                                                    %
% This program is free software: you can distribute it and/or modify %
% it under the terms of GNU General Public License as published by   %
% the Free Software Foundation, either version 3 of the License or   %
% (at your option) any later version.                                %
%                                                                    %
% This program is distributed in the hope that it will be useful,    %
% but WITHOUT ANY WARRANTY; without even the implied warranty of     %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the       %
% GNU General Public License for more details.                       %
%                                                                    %
% You should have received a copy of the GNU General Public License  %
% along with This program. If not see <http://www.gnu.org/licenses/>.%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#!/usr/bin/octave -qf

%--------------------------------------------------------------------
% This script is used to extraing slices out of the dpa binary file
% It is universal for dumped dpa file from steady-state or TDP. 
% Author: Tong ZHANG
% Created Time: Sep. 12, 2012
%-------------------------------------------------------------------

function give_warning()
	printf("Usage: readdpa.m [option] dpafile outfile npart datafmt [slices]\n");
	printf("\t dpafile: filename of the binary dpa file to read\n");
	printf("\t outfile: name head of the ascii slice files to write\n");
	printf("\t npart  : particle number of the dpa file\n");
	printf("\t datafmt: data format of the output, bin or asc\n");
	printf("\t slices : range of the slices to be extracted (optional)\n");
	printf("\t          format min:step:max, 1:1:nslice by default\n");
	printf("\n");
	printf("Option:\n");
	printf("\t--info\tShow the meanings of each column of the ascfile\n");
end

function give_col_meanings()
	printf("  The 6 columns represent the 6 dimensional phase space\n");
	printf("  in longitudinal and transverse, originally\n")
	printf("  gamma theta x y xp and yp, where {x,y}p stands for beta{x,y}*gamma\n");
	printf("  gamma theta x y xp yp ==> gamma theta x y betax(xp/gamma) betay(yp/gamma)\n");
	printf("  emitx = sqrt(<x^2><x'^2>-<xx'>^2)\n");
	printf("  rmsx  = sqrt(<x^2>)\n");
	printf("  sigma_u^2  = <u^2>  = emit_u*beta_u\n");
	printf("  sigma_u'^2 = <u'^2> = emit_u*gamma_u\n");
	printf("  <u*u'> = -emit_u*alpha_u\n");
end

args=argv();

if size(args)(1) == 1 && args{1} == '--info'
	give_col_meanings();
	exit;
end

if size(args)(1) < 4
	give_warning();
	exit;
end

% read dpa file
infile  = args{1};          	% file name of the input dpa file from Genesis 1.3
outfile = args{2};          	% ascii out file head, for slices, the full name 
								% will be slices+(slice#)
npart   = str2num(args{3}); 	% particle number

datafmt = args{4}; 				% bin or asc (i.e. binary or ascii)

sliceRange = 0; 				% define sliceRange as 1, change if args{4} given

if size(args)(1) == 5 				% get the slice range to extract,
	sliceRange=str2num(args{5});% e.g. if args{4} = '1:2:5', then sliceRange = [1,3,5]
end

%---------------------------------------------------------------------------
% gamma theta x y xp yp ===> gamma theta x y betax(xp/gamma) betay(yp/gamma)
% emitx   = sqrt(<x^2><x'^2>-<xx'>^2)
% rmsx    = sqrt(<x^2>)
% sigma_u^2 = <u^2>  = emit_u*beta_u
% sigma_u'^2= <u'^2> = emit_u*gamma_u
% <u*u'> = -emit_u*alpha_u
%---------------------------------------------------------------------------

fid = fopen(infile, 'r');

% get the nslice value from the infile size, double (64 bits, 6 Bytes)
nslice = stat(fid).size/8/npart/6;

nslice
min(sliceRange)

if (sliceRange == 0) || (min(sliceRange) > nslice) % i.e. not given args{5}, sliceRange rolls back to default value
	sliceRange = 1:1:nslice;
end

sliceRange


sliceData = fread(fid,  'double'); 
sliceData = reshape(sliceData, [npart, 6, nslice]);
% sliceData: array with the dim of npart x 6 x nslice
% get the i-th slice data: sliceData(:,:,i), with the dim of npart x 6


% write slice data into outputfiles
if datafmt == 'bin'
	for islice = sliceRange
		outfileName = strcat(outfile, num2str(islice));
		fidout = fopen(outfileName, 'w');
		fwrite(fidout, sliceData(:,:,islice), 'double');
		fclose(fidout);
	end
else % datafmt == asc
	for islice = sliceRange
		outfileName = strcat(outfile, num2str(islice));
		dlmwrite(outfileName, sliceData(:,:,islice), 'delimiter', ' ',...
					'precision', '%.18e');
	end
end
