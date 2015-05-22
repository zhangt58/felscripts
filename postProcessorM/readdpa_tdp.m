#!/usr/bin/octave -qf

%--------------------------------------------------------------------
% This script is used to extraing slices out of the dpa binary file
% Author: Tong ZHANG
% Created Time: Sep. 12, 2012
% Last revised Time: Jan. 22, 2013
% Log:
% 1: Jan. 22, 2013
% 	[1] compatible with .par file processing
% 	[2] add phase advance to each slice
% 	[3] add mymod function to make theta in [-pi:pi]
% 	[4] the theta col will be mymoded, i.e. 2nd-col is modified
% 
%-------------------------------------------------------------------

function give_warning()
	printf("Usage: readdpa.m [option] binfile outfile npart datafmt mflag [slices]\n");
	printf("\t binfile: filename of the binary dpa/par file to read\n");
	printf("\t outfile: name head of the ascii slice files to write\n");
	printf("\t npart  : particle number of the dpa file (per slice)\n");
	printf("\t datafmt: data format of the output, bin or asc\n");
	printf("\t mflag  : whether 2nd col (mod theta col) moded, 1 or 0\n");
	printf("\t slices : range of the slices to be extracted (optional)\n");
	printf("\t          format min:step:max, 1:1:nslice by default\n");
	printf("\t P.S:     slice# of .dpa and zentri# of .par is equivalent\n");
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

function f = mymod(a)
	f = a;
	for i = 1:length(f)
		while f(i) < -pi
			f(i) = f(i) + 2*pi;
		end
		while f(i) > pi
			f(i) = f(i) - 2*pi;
		end
	end
end

args=argv();

if size(args)(1) == 1 && args{1} == '--info'
	give_col_meanings();
	exit;
end

if size(args)(1) < 5
	give_warning();
	exit;
end

% read dpa file
infile  = args{1};          	% file name of the input dpa file from Genesis 1.3
outfile = args{2};          	% ascii out file head, for slices, the full name 
								% will be slices+(slice#)
npart   = str2num(args{3}); 	% particle number

datafmt = args{4}; 				% bin or asc (i.e. binary or ascii)

mflag   = str2num(args{5}); 	% 1 (add 7th col) or 0 (not add 7th col)

sliceRange = 0; 				% define sliceRange as 1, change if args{4} given

if size(args)(1) == 6			% get the slice range to extract,
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


if (sliceRange == 0) || (min(sliceRange) > nslice) % i.e. not given args{5}, sliceRange rolls back to default value
	sliceRange = 1:1:nslice;
end


sliceData = fread(fid,  'double'); 
sliceData = reshape(sliceData, [npart, 6, nslice]);
% sliceData: array with the dim of npart x 6 x nslice
% get the i-th slice data: sliceData(:,:,i), with the dim of npart x 6


% write slice data into outputfiles
if datafmt == 'bin'
	for islice = sliceRange
		outfileName = strcat(outfile, num2str(islice));
		fidout = fopen(outfileName, 'w');
% add 2*pi every one slice
		tmp = sliceData(:,:,islice);
		tmp(:,2) = tmp(:,2) + (islice-1)*2*pi;
		if mflag == 1
			tmp(:,2) = mymod(tmp(:,2));
%		else
%			tmp(:,7) = tmp(:,2);
		end
%		fwrite(fidout, sliceData(:,:,islice), 'double');
		fwrite(fidout, tmp, 'double');
		fclose(fidout);
	end
else % datafmt == asc
	for islice = sliceRange
		outfileName = strcat(outfile, num2str(islice));
		tmp = sliceData(:,:,islice);
%		tmp(:,2) = tmp(:,2) + (islice-1)*2*pi;
		if mflag == 1
			tmp(:,2) = mymod(tmp(:,2));
%		else
%			tmp(:,7) = tmp(:,2);
		end
%		dlmwrite(outfileName, sliceData(:,:,islice), 'delimiter', ' ',...
%					'precision', '%.9e');
		dlmwrite(outfileName, tmp, 'delimiter', ' ',...
					'precision', '%.9e');
	end
end
