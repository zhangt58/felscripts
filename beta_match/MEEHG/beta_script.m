#!/usr/bin/octave -qf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program purpose: EEHG beta match
% Usage: beta_script.m QF QD [+other 28 parameters]
% 		 usually called by shell script
% Revised in 20:13, Jan. 19th, 2013
% Author: Tong ZHANG
% Email: tzhang@sinap.ac.cn
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% function list:
% TransQuadF(): Transmission matrix for focus quadrpole (in x)
% TransQuadD(): Transmission matrix for focus quadrpole (in y)
% TransDrift(): Transmission matrix for drift space
% TransUnduH(): Transmission matrix for planar undulator in x
% TransUnduV(): Transmission matrix for planar undulator in y
% TransChica(): Transmission matrix for chicane
%

function [m]=TransQuadF(k,s)
	a=cos(sqrt(k)*s);
	b=sin(sqrt(k)*s)/sqrt(k);
	c=-sqrt(k)*sin(sqrt(k)*s);
	d=cos(sqrt(k)*s);
	m=[a,b;c,d];
endfunction

function [m]=TransQuadD(k,s)
	a=cosh(sqrt(k)*s);
	b=sinh(sqrt(k)*s)/sqrt(k);
	c=sqrt(k)*sinh(sqrt(k)*s);
	d=cosh(sqrt(k)*s);
	m=[a,b;c,d];
endfunction

function [m]=TransDrift(s)
	m=[1,s;0,1];
endfunction

function [m]=TransUnduH(s)
	m=[1,s;0,1];
endfunction

function [m]=TransUnduV(k,s)
	m=TransQuadF(k,s);
endfunction

function [m]=TransEdgeX(theta,rho)
	m=[1,0;tan(theta/rho),1];
endfunction

function [m]=TransEdgeY(theta,rho)
	m=[1,0;-tan(theta/rho),1];
endfunction

function [m]=TransSectX(theta,rho)
	m=[cos(theta),rho*sin(theta);-sin(theta)/rho,cos(theta)];
endfunction

function [m]=TransSectY(theta,rho)
	m=[1,rho*theta;0,1];
endfunction

function [m]=TransChica(imagl,idril,ibfield,gamma0,xoy)
	m0 = 9.10938215e-31;
	e0 = 1.602176487e-19;
	c0 = 299792458;
	rho=sqrt(gamma0^2-1)*m0*c0/ibfield/e0;
	theta=asin(imagl/rho);
	ld=idril;
	mx=TransDrift(idril)*TransSectX(theta,rho)*TransEdgeX(theta,rho)*TransDrift(ld)*TransEdgeX(-theta,-rho)*TransSectX(-theta,-rho)*TransDrift(ld)*TransSectX(-theta,-rho)*TransEdgeX(-theta,-rho)*TransDrift(ld)*TransEdgeX(theta,rho)*TransSectX(theta,rho)*TransDrift(idril);
	my=TransDrift(idril)*TransSectY(theta,rho)*TransEdgeY(theta,rho)*TransDrift(ld)*TransEdgeY(-theta,-rho)*TransSectY(-theta,-rho)*TransDrift(ld)*TransSectY(-theta,-rho)*TransEdgeY(-theta,-rho)*TransDrift(ld)*TransEdgeY(theta,rho)*TransSectY(theta,rho)*TransDrift(idril);
	if(xoy==1) % transmission matrix in x
		m=mx;
	else
		m=my;
	endif
endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
args=argv();
% format long
kp      = str2num(args{1});	% QF: quadF gradient [T/m]
kn      = str2num(args{2});	% QD: quadD gradient [T/m]

if(kp==0)
    kp=kp+eps;
endif
if(kn==0)
    kn=kn+eps;
endif

%%%%%%%%%%%%%%%%%%%%%%%parameter list loading%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma0  = str2num(args{3});	% beam energy, Lorentz factor
emitn   = str2num(args{4});	% normalized emittance 					  [m]

lambdam1= str2num(args{5});	% period of mod-1						  [m]
am1     = str2num(args{6});	% normalized undulator parameter of mod-1

lambdam2= str2num(args{7});	% period of mod-2						  [m]
am2     = str2num(args{8});	% normalized undulator parameter of mod-2

imagl1  = str2num(args{9});	% effective bend length of chicane-1 	  [m]
idril1  = str2num(args{10});% drift length between bends of chicane-1 [m]
ibfield1= str2num(args{11});% bend magnetic strength of chicane-1 	  [T]

imagl2  = str2num(args{12});% effective bend length of chicane-2 	  [m]
idril2  = str2num(args{13});% drift length between bends of chicane-2 [m]
ibfield2= str2num(args{14});% bend magnetic strength of chicane-2	  [T]

lambdau = str2num(args{15});% radiator period						  [m]
au      = str2num(args{16});% normalized radiator parameter

lo1     = str2num(args{17});% drift length before mod-1  [mod-1 period]
lm1     = str2num(args{18});% mod-1 length               [mod-1 period]
lo2     = str2num(args{19});% drift length after mod-1   [mod-1 period]

lo3     = str2num(args{20});% drift length before mod-2  [mod-2 period]
lm2     = str2num(args{21});% mod-2 length               [mod-2 period]
lo4     = str2num(args{22});% drift length after mod-2   [mod-2 period]

lo5     = str2num(args{23});% drift legnth before QF1          [rad period]
lqf     = str2num(args{24});% focussing quadrupole length,QF1  [rad period]
lo6     = str2num(args{25});% drift length between QF1 and rad [rad period]
lur     = str2num(args{26});% length of radiator (one section) [rad period]
lo7     = str2num(args{27});% drift length between rad and QF2 [rad period]
lqd     = str2num(args{28});% defocussing quadrupole length,QF2[rad period]

%gamma0
%emitn
%lambdam1
%am1
%lambdam2
%am2
%imagl1
%idril1
%ibfield1
%imagl2
%idril2
%ibfield2
%lambdau
%au
%lo1
%lm1
%lo2
%lo3
%lm2
%lo4
%lo5
%lqf
%lo6
%lur
%lo7
%lqd
%exit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% physical constants
m0 = 9.10938215e-31;	% rest mass of electron					[kg]
e0 = 1.602176487e-19;	% electron charge unit					[C]
c0 = 299792458;			% light speed							[m/s]

%
ku = 2*pi/lambdau;		% wavenumber of radiator				[1/m]
Ku = sqrt(2)*au;		% radiator parameter
lambdas = lambdau/2/gamma0^2*(1+au^2)*1e9; % resonant FEL wavelength [nm]
Kbeta = 1/2*(Ku*ku/gamma0)^2; % equivalent radiator y-focussing parameter
Kp = e0*kp/m0/c0/sqrt(gamma0^2-1); % QF focussing parameter
Kn = e0*kn/m0/c0/sqrt(gamma0^2-1); % QD focussing parameter

Km1 = sqrt(2)*am1;		%undulator parameter of mod-1
km1 = 2*pi/lambdam1;	%wavenumber of mod-1			[1/m]
Kbetam1 = 1/2*(Km1*km1/gamma0)^2;%equivalent y-focussing parameter of mod-1

Km2 = sqrt(2)*am2;		%undulator parameter of mod-2
km2 = 2*pi/lambdam2;	%wavenumber of mod-2			[1/m]
Kbetam2 = 1/2*(Km2*km2/gamma0)^2;%equivalent y-focussing parameter of mod-2

n0 = lo5;				% drift length before QF
%define FODO lattice
n1 = lqf/2;				% QF/2, half QF
n2 = lo6;				% O6
n3 = lur;				% UR
n4 = lo7;				% O7
n5 = lqd;				% QD
n6 = n2;				% O6
n7 = n3;				% UR
n8 = n4;				% O7
n9 = n1;				% QF/2

%Horizontal Matrix 
mx = TransQuadF(Kp,n1*lambdau)*TransDrift(n2*lambdau)*TransUnduH(n3*lambdau)*TransDrift(n4*lambdau)*TransQuadF(Kn,n5*lambdau)*TransDrift(n6*lambdau)*TransUnduH(n7*lambdau)*TransDrift(n8*lambdau)*TransQuadF(Kp,n9*lambdau);
if((mx(1,1)+mx(2,2))^2>4 || mx(1,2) <= 0)
	exit(1);
endif

%Vertical Matrix 
my = TransQuadF(-Kp,n1*lambdau)*TransDrift(n2*lambdau)*TransUnduV(Kbeta,n3*lambdau)*TransDrift(n4*lambdau)*TransQuadF(-Kn,n5*lambdau)*TransDrift(n6*lambdau)*TransUnduV(Kbeta,n7*lambdau)*TransDrift(n8*lambdau)*TransQuadF(-Kp,n9*lambdau);
if((my(1,1)+my(2,2))^2>4 || my(1,2) <= 0)
	exit(1);
endif

%%%%%%%%%%%%%%twiss parameters of FODO%%%%%%%%%%%%%%
% mx
alphax = (mx(1,1)-mx(2,2))/sqrt(4-(mx(1,1)+mx(2,2))^2);
betax  = 2*mx(1,2)/sqrt(4-(mx(1,1)+mx(2,2))^2);
gammax = (1+alphax^2)/betax;
% my
alphay = (my(1,1)-my(2,2))/sqrt(4-(my(1,1)+my(2,2))^2);
betay  = 2*my(1,2)/sqrt(4-(my(1,1)+my(2,2))^2);
gammay = (1+alphay^2)/betay;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%match to the entrance of radiator%%%%%%%%
% Forward match O5 (n0) + QF/2 (n1)
% 0 -> O5 -> QF/2 ->r  (FODO)
% -->0 (twiss parameters to be matched out) 
% -->r (twiss parameters already calculated)
% ==> r = M(QF/2).M(O5).0 = A.0
% ==> 0 = inv(A).r
% ==> -->0 = TwissTrans(inv(A)).-->r
%
AX0 = TransQuadF(Kp,n1*lambdau)*TransDrift(n0*lambdau);
AY0 = TransQuadF(-Kp,n1*lambdau)*TransDrift(n0*lambdau);
AX0 = inverse(AX0);
AY0 = inverse(AY0);
Nx0 = [	AX0(1,1)^2,		-2*AX0(1,1)*AX0(1,2),			AX0(1,2)^2;
	-AX0(1,1)*AX0(2,1),	1+2*AX0(1,2)*AX0(2,1),	-AX0(1,2)*AX0(2,2);
		AX0(2,1)^2,		-2*AX0(2,1)*AX0(2,2),			AX0(2,2)^2];

Ny0 = [	AY0(1,1)^2,		-2*AY0(1,1)*AY0(1,2),			AY0(1,2)^2;
	-AY0(1,1)*AY0(2,1),	1+2*AY0(1,2)*AY0(2,1),	-AY0(1,2)*AY0(2,2);
		AY0(2,1)^2,		-2*AY0(2,1)*AY0(2,2),			AY0(2,2)^2];
Bx0 = Nx0*[betax;alphax;gammax]; % twiss parameters transmission in x
By0 = Ny0*[betay;alphay;gammay]; % twiss parameters transmission in y
% matched twiss parameters at the beginning of GENESIS radiator lattice file
alphax0 = Bx0(2);
alphay0 = By0(2);
betax0  = Bx0(1);
betay0  = By0(1);
gammax0 = Bx0(3);
gammay0 = By0(3);
sigmax0 = sqrt(betax0*emitn/gamma0);
sigmay0 = sqrt(betay0*emitn/gamma0);

%%%%%%%%match to mod-2%%%%%%%%%%%%%%%
% Forward match O3 + Chicane-2 (chi-2) + O4
% 1 -> O3 -> M2 -> O4 -> chi-2 -> 0 (rad)
% -->1 (twiss parameters to be matched out) 
% -->0 (twiss parameters already calculated)
% ==> 0 = M(chi-2).M(O4).M(M2).M(O3).1 = A.1
% ==> 1 = inv(A).0
% ==> -->1 = TwissTrans(inv(A)).-->0
%

mi0 = lo3;			% dirft length before mod-2
mi1 = lm2;			% length of mod-2
mi2 = lo4;			% drift length after mod-2
AX1 = TransChica(imagl2,idril2,ibfield2,gamma0,1)*TransDrift(mi2*lambdam2)*TransUnduH(mi1*lambdam2)*TransDrift(mi0*lambdam2);
AY1 = TransChica(imagl2,idril2,ibfield2,gamma0,0)*TransDrift(mi2*lambdam2)*TransUnduV(Kbetam2,mi1*lambdam2)*TransDrift(mi0*lambdam2);
AX1 = inverse(AX1);
AY1 = inverse(AY1);
Nx1 = [	AX1(1,1)^2,		-2*AX1(1,1)*AX1(1,2),			AX1(1,2)^2;
	-AX1(1,1)*AX1(2,1),	1+2*AX1(1,2)*AX1(2,1),	-AX1(1,2)*AX1(2,2);
		AX1(2,1)^2,		-2*AX1(2,1)*AX1(2,2),			AX1(2,2)^2];

Ny1 = [	AY1(1,1)^2,		-2*AY1(1,1)*AY1(1,2),			AY1(1,2)^2;
	-AY1(1,1)*AY1(2,1),	1+2*AY1(1,2)*AY1(2,1),	-AY1(1,2)*AY1(2,2);
		AY1(2,1)^2,		-2*AY1(2,1)*AY1(2,2),			AY1(2,2)^2];
Bx1 = Nx1*[betax0;alphax0;gammax0];% twiss parameters transmission in x
By1 = Ny1*[betay0;alphay0;gammay0];% twiss parameters transmission in y
% matched twiss parameters for mod-2
alphax1 = Bx1(2);
alphay1 = By1(2);
betax1  = Bx1(1);
betay1  = By1(1);
gammax1 = Bx1(3);
gammay1 = By1(3);
sigmax1 = sqrt(betax1*emitn/gamma0);
sigmay1 = sqrt(betay1*emitn/gamma0);

%%%%%%%%match to mod-1%%%%%%%%%%%%%%%
% Forward match O1 + Chicane-1 (chi-1) + O2
% 2 -> O1 -> M1 -> O2 -> chi-1 -> 1 (rad)
% -->2 (twiss parameters to be matched out) 
% -->1 (twiss parameters already calculated)
% ==> 1 = M(chi-1).M(O2).M(M1).M(O1).2 = A.2
% ==> 2 = inv(A).1
% ==> -->2 = TwissTrans(inv(A)).-->1
%

mj0 = lo1;			% dirft length before mod-1
mj1 = lm1;			% length of mod-1
mj2 = lo2;			% drift length after mod-1
AX2 = TransChica(imagl1,idril1,ibfield1,gamma0,1)*TransDrift(mj2*lambdam1)*TransUnduH(mj1*lambdam1)*TransDrift(mj0*lambdam1);
AY2 = TransChica(imagl1,idril1,ibfield1,gamma0,0)*TransDrift(mj2*lambdam1)*TransUnduV(Kbetam1,mj1*lambdam1)*TransDrift(mj0*lambdam1);
AX2 = inverse(AX2);
AY2 = inverse(AY2);
Nx2 = [	AX2(1,1)^2,		-2*AX2(1,1)*AX2(1,2),			AX2(1,2)^2;
	-AX2(1,1)*AX2(2,1),	1+2*AX2(1,2)*AX2(2,1),	-AX2(1,2)*AX2(2,2);
		AX2(2,1)^2,		-2*AX2(2,1)*AX2(2,2),			AX2(2,2)^2];

Ny2 = [	AY2(1,1)^2,		-2*AY2(1,1)*AY2(1,2),			AY2(1,2)^2;
	-AY2(1,1)*AY2(2,1),	1+2*AY2(1,2)*AY2(2,1),	-AY2(1,2)*AY2(2,2);
		AY2(2,1)^2,		-2*AY2(2,1)*AY2(2,2),			AY2(2,2)^2];
Bx2 = Nx2*[betax1;alphax1;gammax1];% twiss parameters transmission in x
By2 = Ny2*[betay1;alphay1;gammay1];% twiss parameters transmission in y
% matched twiss parameters for mod-1
alphax2 = Bx2(2);
alphay2 = By2(2);
betax2  = Bx2(1);
betay2  = By2(1);
gammax2 = Bx2(3);
gammay2 = By2(3);
sigmax2 = sqrt(betax2*emitn/gamma0);
sigmay2 = sqrt(betay2*emitn/gamma0);


%%%%%%%%%%%%%%%%%%%%%%%%results output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rad   ----> 0
%mod-2 ----> 1
%mod-1 ----> 2

alphax0
alphay0
sigmax0
sigmay0
alphax1
alphay1
sigmax1
sigmay1
alphax2
alphay2
sigmax2
sigmay2
