#!/usr/bin/octave -qf

%generate Gaussian seed laser file:seed.in
%argv1: peakpower [W]
%argv2: rayleigh length [m]
%argv3: offset with center(z=0) [meter]
%argv4: seed file name

args=argv();
pradmax  = str2num(args{1});
zr       = str2num(args{2});
zof      = str2num(args{3});
seedfile = args{4};

c0     = 299792458.0;
curlen = 1e-3/c0;
% 1 picosecond (300*^-6 m)

z = (-10*curlen:10e-15:10*curlen)*c0;
% [m]

% seed laser parameters
FWHMt  = 8e-12; %seed width in FWHM (sec)
sigmat = FWHMt/(2*sqrt(2*log(2)));% [sec]
prad0  = pradmax*exp(-(z).^2/2/(sigmat*c0)^2);
zwaist = 0;
z      = z-zof;

dlmwrite(seedfile,[z',prad0',zr*ones(size(z))',zwaist*ones(size(z))'],...
    'delimiter',' ','precision','%.6e')
