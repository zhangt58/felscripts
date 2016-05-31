#!/usr/bin/octave -qf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%function list:
%TransQuadF()
%TransQuadF()
%TransDrift()
%TransUnduH()
%TransUnduV()
%TransChica()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HGHG beta match
%Usage: beta_script.m QF QD +other 18 parameters
%
%
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
	if(xoy==1)
		m=mx;
	else
		m=my;
	endif
endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
args=argv();
%format long
kp      = str2num(args{1});	%QF
kn      = str2num(args{2});	%QD

if(kp==0)
    kp=kp+eps;
endif
if(kn==0)
    kn=kn+eps;
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%parameter list loading%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma0  = str2num(args{3});	%beam energy
emitn   = str2num(args{4});	%normalized emittance 					[m]

lambdam = str2num(args{5});	%period of modulator					[m]
am      = str2num(args{6});	%normalized modulator parameter

imagl   = str2num(args{7});	%effective bend length of chicane 		[m]
idril   = str2num(args{8});	%drift length between bends of chicane	[m]
ibfield = str2num(args{9});%bend magnetic strength of chicane		[T]

lambdau = str2num(args{10});%radiator period						[m]
au      = str2num(args{11});%normalized radiator parameter

lo1     = str2num(args{12});%drift length before modulator,			unit: modulator period
lum     = str2num(args{13});%modulator length, 						unit: modulator period
lo2     = str2num(args{14});%drift length after modulator,			unit: modulator period
lo3     = str2num(args{15});%drift legnth before QF1,after chicane, unit: radiator period
lf      = str2num(args{16});%focussing quadrupole length,QF1,		unit: radiator period
lo4     = str2num(args{17});%drift length between QF1,				unit: radiator period
lur     = str2num(args{18});%length of radiator, 					unit: radiator period
lo5     = str2num(args{19});%drift length between undulator and QF2,unit: radiator period
ld      = str2num(args{20});%defocussing quadrupole length,QF2,		unit: radiator period

%gamma0
%emitn
%lambdam
%am
%imagl
%idril
%ibfield
%lambdau
%au
%lo1
%lum
%lo2
%lo3
%lf
%lo4
%lur
%lo5
%ld
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m0 = 9.10938215e-31;	%rest mass of electron					[kg]
e0 = 1.602176487e-19;	%electron charge unit					[C]
c0 = 299792458;			%light speed							[m/s]

ku=2*pi/lambdau;		%wavenumber of radiator					[1/m]
Ku=sqrt(2)*au;			%radiator parameter
lambdas=lambdau/2/gamma0^2*(1+au^2)*1e9;%resonant FEL wavelength[nm]
Kbeta=1/2*(Ku*ku/gamma0)^2;		%equivalent radiator y-focussing parameter
Kp=e0*kp/m0/c0/sqrt(gamma0^2-1);%QF focussing parameter
Kn=e0*kn/m0/c0/sqrt(gamma0^2-1);%QD focussing parameter
Km=sqrt(2)*am;			%modulator parameter
km=2*pi/lambdam;		%wavenumber of modulator				[1/m]
Kbetam=1/2*(Km*km/gamma0)^2;%equivalent modulator y-focussing parameter

%define FODO lattice
n0 = lo3;				%drift length before F
n1 = lf/2;				%F/2
n2 = lo4;				%O4
n3 = lur;				%U
n4 = lo5;				%O5
n5 = ld;				%D
n6 = n2;				%O4
n7 = n3;				%U
n8 = n4;				%O5
n9 = n1;				%F/2

%Horizontal Matrix 
mx=TransQuadF(Kp,n1*lambdau)*TransDrift(n2*lambdau)*TransUnduH(n3*lambdau)*TransDrift(n4*lambdau)*TransQuadF(Kn,n5*lambdau)*TransDrift(n6*lambdau)*TransUnduH(n7*lambdau)*TransDrift(n8*lambdau)*TransQuadF(Kp,n9*lambdau);
if((mx(1,1)+mx(2,2))^2>4 || mx(1,2) <= 0)
	exit(1);
endif

%Vertical Matrix 
my=TransQuadF(-Kp,n1*lambdau)*TransDrift(n2*lambdau)*TransUnduV(Kbeta,n3*lambdau)*TransDrift(n4*lambdau)*TransQuadF(-Kn,n5*lambdau)*TransDrift(n6*lambdau)*TransUnduV(Kbeta,n7*lambdau)*TransDrift(n8*lambdau)*TransQuadF(-Kp,n9*lambdau);
if((my(1,1)+my(2,2))^2>4 || my(1,2) <= 0)
	exit(1);
endif

%%%%%%%%%%%%%%twiss parameters of FODO%%%%%%%%%%%%%%
%mx
alphax=(mx(1,1)-mx(2,2))/sqrt(4-(mx(1,1)+mx(2,2))^2);
betax=2*mx(1,2)/sqrt(4-(mx(1,1)+mx(2,2))^2);
gammax=(1+alphax^2)/betax;
%my
alphay=(my(1,1)-my(2,2))/sqrt(4-(my(1,1)+my(2,2))^2);
betay=2*my(1,2)/sqrt(4-(my(1,1)+my(2,2))^2);
gammay=(1+alphay^2)/betay;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%match to the entrance of radiator%%%%%%%%
%Forward match O+F/2
AX=TransQuadF(Kp,n1*lambdau)*TransDrift(n0*lambdau);
AY=TransQuadF(-Kp,n1*lambdau)*TransDrift(n0*lambdau);
AX=inverse(AX);
AY=inverse(AY);
Nx=[	AX(1,1)^2,		-2*AX(1,1)*AX(1,2),			AX(1,2)^2;
	-AX(1,1)*AX(2,1),	1+2*AX(1,2)*AX(2,1),	-AX(1,2)*AX(2,2);
		AX(2,1)^2,		-2*AX(2,1)*AX(2,2),			AX(2,2)^2];

Ny=[	AY(1,1)^2,		-2*AY(1,1)*AY(1,2),			AY(1,2)^2;
	-AY(1,1)*AY(2,1),	1+2*AY(1,2)*AY(2,1),	-AY(1,2)*AY(2,2);
		AY(2,1)^2,		-2*AY(2,1)*AY(2,2),			AY(2,2)^2];
Bx=Nx*[betax;alphax;gammax];
By=Ny*[betay;alphay;gammay];
%%matched twiss parameters at the beginning of GENESIS radiator lattice file
alphax0=Bx(2);
alphay0=By(2);
betax0=Bx(1);
betay0=By(1);
gammax0=Bx(3);
gammay0=By(3);
sigmax0=sqrt(betax0*emitn/gamma0);
sigmay0=sqrt(betay0*emitn/gamma0);
%%SASE beta matched parameters (if only radiator needed)
%betax0
%betay0
%gammax0
%gammay0
%disp([alphax0;alphay0;sigmax0;sigmay0])
%matched beam at the exit of chicane
%alphax0;
%alphay0;
%sigmax0;
%sigmay0;

%%%%%%%%%%%%Forward match mod+Chicane, find the required twiss parameter in mod%%%%%%%%%%%%%%%%%
%AX=TransQuadF(Kp,n1*lambdau)*TransDrift(n2*lambdau)*TransChica(0.15,0.285,0.0581,gamma0,1)*TransUnduH(nmod*lambdam);
%AY=TransQuadF(-Kp,n1*lambdau)*TransDrift(n2*lambdau)*TransChica(0.15,0.285,0.0581,gamma0,0)*TransUnduV(Kbetam,nmod*lambdam);
m0=lo1;			%dirft length before modulator
m1=lum;			%modulator length
m2=lo2;			%drift length after modulator
AX=TransChica(imagl,idril,ibfield,gamma0,1)*TransDrift(m2*lambdam)*TransUnduH(m1*lambdam)*TransDrift(m0*lambdam);
AY=TransChica(imagl,idril,ibfield,gamma0,0)*TransDrift(m2*lambdam)*TransUnduV(Kbetam,m1*lambdam)*TransDrift(m0*lambdam);
AX=inverse(AX);
AY=inverse(AY);
Nx=[	AX(1,1)^2,		-2*AX(1,1)*AX(1,2),			AX(1,2)^2;
	-AX(1,1)*AX(2,1),	1+2*AX(1,2)*AX(2,1),	-AX(1,2)*AX(2,2);
		AX(2,1)^2,		-2*AX(2,1)*AX(2,2),			AX(2,2)^2];

Ny=[	AY(1,1)^2,		-2*AY(1,1)*AY(1,2),			AY(1,2)^2;
	-AY(1,1)*AY(2,1),	1+2*AY(1,2)*AY(2,1),	-AY(1,2)*AY(2,2);
		AY(2,1)^2,		-2*AY(2,1)*AY(2,2),			AY(2,2)^2];
Bx=Nx*[betax0;alphax0;gammax0];
By=Ny*[betay0;alphay0;gammay0];
alphax1=Bx(2);
alphay1=By(2);
betax1=Bx(1);
betay1=By(1);
gammax1=Bx(3);
gammay1=By(3);
sigmax1=sqrt(betax1*emitn/gamma0);
sigmay1=sqrt(betay1*emitn/gamma0);
%betax1
%betay1
%gammax1
%gammay1
%disp([alphax1;alphay1;sigmax1;sigmay1])
%matched beam at the entrance of modulator

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%results output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%radiator   ----> 0
%modulator  ----> 1
alphax0
alphay0
sigmax0
sigmay0
alphax1
alphay1
sigmax1
sigmay1
