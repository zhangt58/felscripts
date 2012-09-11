#!/usr/bin/octave -qf

%--------------------------------------------------------------------------%
% This script is used to extra dpa info from the GENESIS output file by 
% Octve or Matlab
% Author: Tong ZHANG
% Sep. 5th, 2012
%--------------------------------------------------------------------------%

function give_warning()
	printf("Usage: readdpa.m [option] dpafile ascfile npart\n");
	printf("\t dpafile: filename of the binary dpa file to read\n");
	printf("\t ascfile: filename of the ascii file to write\n");
	printf("\t npart  : particle number of the dpa file\n");
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

if size(args)(1) < 3
	give_warning();
	exit;
end

% read dpa file
infile  = args{1};          % out.dpa file
outfile = args{2};          % ascii out file
npart   = str2num(args{3}); % particle number

%---------------------------------------------------------------------------
% gamma theta x y xp yp ===> gamma theta x y betax(xp/gamma) betay(yp/gamma)
% emitx   = sqrt(<x^2><x'^2>-<xx'>^2)
% rmsx    = sqrt(<x^2>)
% sigma_u^2 = <u^2>  = emit_u*beta_u
% sigma_u'^2= <u'^2> = emit_u*gamma_u
% <u*u'> = -emit_u*alpha_u
%---------------------------------------------------------------------------

fileid = fopen(infile, 'r');
a = fread(fileid,'float64');
par = reshape(a,npart,6);
%par(:,2)=mod(par(:,2),2*pi);
%plot(par(:,2),par(:,1),'.','MarkerSize',3)
dlmwrite(outfile,par,'delimiter',' ','precision','%.18e')
%abs(sum(exp(-2*1i*par(:,2))))/npart
