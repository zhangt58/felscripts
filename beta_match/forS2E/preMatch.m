#!/usr/bin/octave -qf

% prematch for electron beam from elegant and the entrance of undulator
% i.e. manipulate the distfile with tranverse matrix
% 
% 
% [1] -> M.[0]
% [0]: twiss parameters calculated from elegant output file (distfile), 
% (alpha, beta, gamma)
% [1]: matched twiss parameters in modulator (HGHG) and radiator (SASE)
% 
% use the calculated M to manipulate the whole distfile
%
% updated: Feb. 2nd, 2013 
%
args = argv();
distfile= args{1};
newdist = args{2};
% alpha and beta of the FEL section (x and y)
alphax1 = str2num(args{3});
betax1  = str2num(args{4});
alphay1 = str2num(args{5});
betay1  = str2num(args{6});

% alpha and beta of the distfile (x and y)
% read from *.twi
alphax0 = str2num(args{7});
betax0  = str2num(args{8});
alphay0 = str2num(args{9});
betay0  = str2num(args{10});

nline = str2num(args{11});

dphi=pi/2;

mx11 = sqrt(betax1/betax0)*(cos(dphi)+alphax0*sin(dphi));
mx12 = sqrt(betax1*betax0)*sin(dphi);
mx21 = -1/sqrt(betax0*betax1)*((1+alphax0*alphax1)*sin(dphi)+(alphax1-alphax0)*cos(dphi));
mx22 = sqrt(betax0/betax1)*(cos(dphi)-alphax1*sin(dphi));
%mx = [  mx11, mx12;
%		mx21, mx22  ];

my11 = sqrt(betay1/betay0)*(cos(dphi)+alphay0*sin(dphi));
my12 = sqrt(betay1*betay0)*sin(dphi);
my21 = -1/sqrt(betay0*betay1)*((1+alphay0*alphay1)*sin(dphi)+(alphay1-alphay0)*cos(dphi));
my22 = sqrt(betay0/betay1)*(cos(dphi)-alphay1*sin(dphi));
%my = [  my11, my12;
%		my21, my22  ];

% distfile transformation, (x1, x1') = M.(x0, x0')
fidin  = fopen(distfile,'r');
fidout = fopen(newdist,'w');
for i=1:nline
	cline = fgetl(fidin);
	rline = str2num(cline);
	t 	  = rline(1);
	gam0  = rline(2);
	x 	  = rline(3)*mx11+rline(5)*mx12;
	y 	  = rline(4)*my11+rline(6)*my12;
	betax = rline(3)*mx21+rline(5)*mx22;
	betay = rline(4)*my21+rline(6)*my22;
	fprintf(fidout,'%.16e %.16e %.16e %.16e %.16e %.16e\n', ...
				t, gam0, x, y, betax, betay);
end
fclose(fidin);
fclose(fidout);
