% post-processors
% resolve result files in "./EEHGdat/res*" 
% power density
% spectra density

%% Loading result files
nslice = 2277;
resPower = zeros(420,nslice); % FEL power 
resPhase = zeros(420,nslice); % FLE phase
resPhrms = zeros(420,nslice); % FEL beam size
resBunch = zeros(420,nslice); % Bunching factor
resXrms  = zeros(420,nslice); % X beam size
resYrms  = zeros(420,nslice); % Y beam size
resEsprd = zeros(420,nslice); % Energy spread
for i=1:nslice
    fname = strcat('./mEEHGdat/res',num2str(i));
    tmp = load(fname);
    resPower(:,nslice+1-i) = tmp(:,1);
    resPhase(:,nslice+1-i) = tmp(:,2);
    resPhrms(:,nslice+1-i) = tmp(:,3);
    resBunch(:,nslice+1-i) = tmp(:,4);
    resXrms(:,nslice+1-i)  = tmp(:,5);
    resYrms(:,nslice+1-i)  = tmp(:,6);
    resEsprd(:,nslice+1-i) = tmp(:,7);
end
%% Show power
s = (0:nslice-1)*232.1e-9/3e8*1e12;
z = (0:420-1)*0.025;
figure(1)
[S,Z] = meshgrid(s,z);
contourf(S,Z,resPower,100);
shading flat
colorbar
xlabel('t [ps]')
ylabel('z [m]')

%% Calculate spectra
xlamds = 232.1; % nm
zsep = 1;
specArray = zeros(420,nslice);
for idx = 1:420
    p = resPower(idx,:);
    phi = resPhase(idx,:);
    [l,pl] = FELspectra(zsep,p,phi,xlamds,nslice);
    specArray(idx,:) = pl;
end
%% show spectra
figure(2)
[xlamdsArray,ZZ] = meshgrid(l,z);
contourf(xlamdsArray,ZZ,specArray,200)
shading flat
colorbar
xlabel('FEL wavelength [nm]')
ylabel('z [m]')
xlim([230,235])
ylim([5,10.475])

%% Show power profile and spectra at maximum
%[idxx,idxy]=find(resPower==max(max(resPower)));
idxx=260;
figure(3)
plot(s,resPower(idxx,:)/1e6,'r-','LineWidth',2)
xlabel('t [ps]')
ylabel('FEL power [MW]')
figure(4)
plot(s,resPhase(idxx,:),'r-','LineWidth',2)
xlabel('t [ps]')
ylabel('FEL phase [rad]')
figure(5)
plot(l,specArray(idxx,:),'b-','LineWidth',2)
xlim([200,240])
xlabel('FEL wavelength [nm]')
ylabel('P(\lambda) [a.u.]')

%% gaincurve
avgP = zeros(420,1);
maxP = zeros(420,1);
Pene = zeros(420,1);
for i = 1:420
    avgP(i) = mean(resPower(i,:));
    maxP(i) = max(resPower(i,:));
    Pene(i) = sum(resPower(i,:))*232.1e-9/3e8*1e6; % microJ
end
%%
figure
semilogy(z,avgP,'r-','LineWidth',2)
xlabel('z [m]')
ylabel('<P> [W]')
grid
dlmwrite('z_avgP.dat',[z',avgP,Pene],'precision','%.6e','delimiter',' ')
%% save data
save('mEEHGdat.mat','nslice', ...
                   'resPower', ...
                   'resPhase', ...
                   'resPhrms', ...
                   'resBunch', ...
                   'resXrms', ...
                   'resYrms', ...
                   'resEsprd', ...
                   'l', ...
                   'specArray')
