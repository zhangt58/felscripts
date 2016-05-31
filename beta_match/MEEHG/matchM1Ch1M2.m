#!/usr/bin/octave -qf

% twiss parameters match for electron beam between M1-[Chicane1-M2]
% 
% 
% [1] -> M.[0]
% [0]: twiss parameters calculated from dpa file from Mod1
% [1]: matched twiss parameters before Chicane1
%
% 

%% predefined functions

function [m]=TransDrift(s)
	m=[1,s;0,1];
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

%% predefined functions end


args = argv();
beamfile=args{1};

% Twiss parameters know for Mod2
alphax2 = str2num(args{2})
betax2  = str2num(args{3})
alphay2 = str2num(args{4})
betay2  = str2num(args{5})

% pre-Match for Chicane I, find the twiss parameter at the entrance of Chicane I
% (twiss)2 = M21.(twiss)1

d1 = 0;			%dirft length before M1 (*meter*)
d2 = 0;			%drift length before Chicane1 (i.e. after M2)(*meter*)
%% set up of Chicane 1
imagl=
idril=
ibfield=
gamma0=
emitn=
%%%%%%%%%%%%%%%%%%%%
AX=TransDrift(d1)*TransChica(imagl,idril,ibfield,gamma0,1)*TransDrift(d2);
AY=TransDrift(d1)*TransChica(imagl,idril,ibfield,gamma0,0)*TransDrift(d2);
AX=inverse(AX);
AY=inverse(AY);
Nx=[	AX(1,1)^2,		-2*AX(1,1)*AX(1,2),			AX(1,2)^2;
	-AX(1,1)*AX(2,1),	1+2*AX(1,2)*AX(2,1),	-AX(1,2)*AX(2,2);
		AX(2,1)^2,		-2*AX(2,1)*AX(2,2),			AX(2,2)^2];

Ny=[	AY(1,1)^2,		-2*AY(1,1)*AY(1,2),			AY(1,2)^2;
	-AY(1,1)*AY(2,1),	1+2*AY(1,2)*AY(2,1),	-AY(1,2)*AY(2,2);
		AY(2,1)^2,		-2*AY(2,1)*AY(2,2),			AY(2,2)^2];
Bx=Nx*[betax2;alphax2];
By=Ny*[betay2;alphay2];
alphax1=Bx(2);
alphay1=By(2);
betax1=Bx(1);
betay1=By(1);
sigmax1=sqrt(betax1*emitn/gamma0);
sigmay1=sqrt(betay1*emitn/gamma0);


% Twiss parameters calculated from m1.out.dpa
=load(beamfile);
alphax0 = mean(bdata(:,12));
betax0  = mean(bdata(:,6).^2.*bdata(:,2)./bdata(:,4)); 
alphay0 = mean(bdata(:,13));
betay0  = mean(bdata(:,7).^2.*bdata(:,2)./bdata(:,5)); 

dphi=pi/2;

mx11 = sqrt(betax1/betax0)*(cos(dphi)+alphax0*sin(dphi));
mx12 = sqrt(betax1*betax0)*sin(dphi);
mx21 = -1/sqrt(betax0*betax1)*((1+alphax0*alphax1)*sin(dphi)+(alphax1-alphax0)*cos(dphi));
mx22 = sqrt(betax0/betax1)*(cos(dphi)-alphax1*sin(dphi));
mx = [  mx11, mx12;
		mx21, mx22  ];

my11 = sqrt(betay1/betay0)*(cos(dphi)+alphay0*sin(dphi));
my12 = sqrt(betay1*betay0)*sin(dphi);
my21 = -1/sqrt(betay0*betay1)*((1+alphay0*alphay1)*sin(dphi)+(alphay1-alphay0)*cos(dphi));
my22 = sqrt(betay0/betay1)*(cos(dphi)-alphay1*sin(dphi));
my = [  my11, my12;
		my21, my22  ];

% beamfile transformation, (x1, x1') = M.(x0, x0')

for i=1:599
	tempx  = bdata(i,8);
	temppx = bdata(i,10); 
	gam    = bdata(i,2);
	bdata(i,8)  = mx11*tempx + mx12*temppx/gam;
	bdata(i,10) = mx21*tempx + mx22*temppx/gam;

	tempy  = bdata(i,9);
	temppy = bdata(i,11); 
	bdata(i,9)  = my11*tempy + my12*temppy/gam;
	bdata(i,11) = my21*tempy + my22*temppy/gam;
end

dlmwrite('newbeam',bdata, 'precision', '%8e', 'delimiter', ' ');
