%
% read trajectory in x from modu output file: 'trajx.dat'
%
%
cd Z:/simulations/EEHG_High/EEHG_10_SDUV/Case2/MOD/mod2
datfile = 'trajx.dat';
fidinfo = dir(datfile);
npart = 10*10000;
totalstep = fidinfo.bytes/8/npart;
fid = fopen(datfile);
AA=fread(fid,[totalstep,npart],'double');
AA=AA';
%%
plot(mean(AA)*1e6,'b-','LineWidth',2)
xlabel('zstep')
ylabel('x [\mu m]')
