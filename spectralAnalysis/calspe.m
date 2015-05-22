#!/usr/bin/octave -qf

%calculate the spectrum of FEL pulse
%argv1: infile, usually spphi
%argv2: outfile, usually spectra
%argv3: N [nslice]
%argv4: l0 [m], central wavelength

args=argv();
infile  = args{1};
outfile = args{2};
N       = str2num(args{3});
l0      = str2num(args{4})*1e9; %m->nm

a    = dlmread(infile);
s    = a(:,1);	%[m]
p    = a(:,3);	%[W]
phi  = a(:,4);	%[rad]

c0   = 299.792458;	%[nm/fs]
w0   = 2*pi*c0/l0;
dt   = (s(end)-s(1))*1e9/c0/N;
dw   = 2*pi/N/dt;
w    = (-N/2:N/2-1)*dw;
absw = w+w0;

et   = sqrt(p).*exp(1i*phi);
pt   = et.*conj(et);
ew   = fftshift(fft(et,N));
pw   = ew.*conj(ew);

temp = find(absw>0);
zp   = temp(1);
l    = 2*pi*c0./absw(end:-1:zp);
pl   = pw(end:-1:zp);

dlmwrite(outfile,[l',pl,pl/max(pl)],'delimiter','\t','precision','%.18e');

%figure

%subplot(3,1,1)
%plot(s*1e6,pt,'r')
%xlabel('t [fs]')
%ylabel('Power [W]')
%grid on

%subplot(3,1,2)
%plot(w,pw)
%xlabel('w [1/fs]')
%ylabel('Intensity [a.u.]')
%grid on

%subplot(3,1,3)
%plot(l,pl)
%xlim([140,160])
%xlabel('wavelength [nm]')
%ylabel('Intensity [a.u.]')
%grid on
