function [l,pl] = FELspectra(zsep,p,phi,xlamds,N)
% dt
% p 
% phi
% xlamds: [nm]
% N: usually nslice
c0   = 299.792458;	%[nm/fs]
w0   = 2*pi*c0/xlamds;
dt   = zsep*xlamds/c0;
dw   = 2*pi/N/dt;
w    = (-N/2:N/2-1)*dw;
absw = w+w0;

et   = sqrt(p).*exp(1i*phi);
% pt   = et.*conj(et);
ew   = fftshift(fft(et,N));
pw   = ew.*conj(ew);

temp = find(absw>0);
zp   = temp(1);
l    = 2*pi*c0./absw(end:-1:zp);
pl   = pw(end:-1:zp);