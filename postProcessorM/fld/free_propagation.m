%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is the specral method for wave propagation in free space
% Haixiao Deng  2013-04-29
% denghaixiao@sinap.ac.cn

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

nslices=1;
z=0.1;
dgrid=1e-3;
ncar=121;
dr=2*dgrid/(ncar-1);
wavelength=523e-9;
k_wave=2*pi/wavelength;
c=3e8;

%%%%%%%%%%%%%%%%%%%%%% Read distribution from .dfl files
FID=fopen('../3_0.out.dfl');
A=fread(FID,[ncar*2,ncar],'double');
fclose(FID);

E0=zeros(ncar,ncar);
EE=zeros(ncar,ncar);
E1=zeros(ncar,ncar);
E=zeros(nslices,ncar,ncar);

for k=1:1:ncar
    x(k)=(k-(ncar+1)/2)*(2*dgrid/(ncar-1));
    for l=1:1:ncar
        y(l)=(l-(ncar+1)/2)*(2*dgrid/(ncar-1));
        E0(k,l)=A((k-1)*2*ncar+2*l-1)+1i*A((k-1)*2*ncar+2*l);
    end
end

P0=abs(E0.^2);
%%
figure(2)
subplot(1,2,1)
contourf(x/1e-6,y/1e-6,P0)
shading flat
%%
for nn=1:1:nslices
    nn
%%%%%%%%%%%%% FFT %%%%%%%%%%%%%%%%%%%%%%
for kk=1:1:ncar
    kx(kk)=(kk-(ncar+1)/2)*2*pi/dr/ncar;
    for ll=1:1:ncar
        ky(ll)=(ll-(ncar+1)/2)*2*pi/dr/ncar;
        for k=1:1:ncar
            EE(kk,ll)=exp(i*kx(kk).*x(k)).*sum(exp(i*ky(ll).*y).*E0(k,:))+EE(kk,ll);
        end
    end
end

EE=EE*dr^2;


%%%%%%%%%%%%% propagation %%%%%%%%%%%%%%
for k=1:1:ncar
    for l=1:1:ncar
        angle=(kx(k)^2+ky(l)^2)/2/k_wave*z;
        EE(k,l)=EE(k,l)*exp(-i*angle);
    end
end


%%%%%%%%%%%%% IFFT %%%%%%%%%%%%%%%%%%%%%
for kk=1:1:ncar
    for ll=1:1:ncar
        for k=1:1:ncar
            E1(kk,ll)=sum(exp(-i*kx(k)*x(kk)).*exp(-i.*ky*y(ll)).*EE(k,:))+E1(kk,ll);
        end
    end
end

E1=E1/4/pi^2*(2*pi/dr/ncar)^2;
P1=abs(E1.^2);

E(nn,:,:)=E1;

end
%%
figure(2)
subplot(1,2,2)
contourf(x/1e-6,y/1e-6,P1)
shading flat
%%

%%%%%%%%%%%%% RMS radiation sieze %%%%%%%%%%
r=0;
for k=1:1:ncar
    for l=1:1:ncar
        r=(x(k)^2+y(l)^2)^0.5*P1(k,l)+r;
    end
end
r=r/sum(sum(P1))