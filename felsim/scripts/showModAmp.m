%%
cd Z:/simulations/EEHG_High/EEHG_10_SDUV/Case2/long
%%
a0 = load('./0_INI/0.out.elg');   % initial dis

%%
a1 = load('./MOD/mod1/mod1c.modu');  % after mod1
figure;
%hold on
plot(a1(:,1),(a1(:,2)-mean(a1(:,2)))/std(a0(:,2)),'r.','MarkerSize',1)
grid
figure;
%hold on
plot(a1(:,1),(a1(:,2)-a0(:,2))/std(a0(:,2)),'b.','MarkerSize',1)
grid

%%
a2 = load('./DS/ds1/ds1.dist');   % after ds1
figure(3);
%hold on
plot(a2(:,1),a2(:,2),'b.','MarkerSize',1)
% plot(mod(a2(:,1)*3e8*2*pi/1320e-9,2*pi),a2(:,2),'b.','MarkerSize',1)
grid
%%
a3 = load('./MOD/mod2/mod2c.modu');  % after mod2
figure(4);
% hold on
plot(a3(:,1),a3(:,2),'b.','MarkerSize',1)
% plot(a3(:,1),(a3(:,2)-a2(:,2))/std(a0(:,2)),'b.','MarkerSize',1)
%%
% plot(a3(:,1)*3e8*2*pi/1320e-9,a3(:,2),'b.','MarkerSize',1)
figure;
plot(mod(a3(:,1)*3e8*2*pi/2400e-9,2*pi),a3(:,2),'b.','MarkerSize',1)

grid
%%
a4 = load('./DS/ds2/ds2.dist');   % after ds2
figure(5);
%hold on
plot(a4(:,1),a4(:,2),'b.','MarkerSize',1)
grid
%%
theta = a4(:,1)*3e8*2*pi/2400e-9;
bfn   = abs(mean(exp(-1i*theta*10.34)));
%%
z4 = a4(:,1)*3e8/2400e-9;
figure
plot(z4-min(z4),a4(:,2),'b.','MarkerSize',1)
%%
idxt = find(z4-min(z4) <=65 & z4-min(z4)>=57);
plot(z4(idxt,1),a4(idxt,2),'b.','MarkerSize',1)
%%
dlmwrite('parfile.asc',a4(idxt,:),'delimiter',' ','precision','%.12e')
%%
theta=a4(idxt,1)*3e8*2*pi/2400e-9;
nharm1=6;
nharm2=15;
xharm = linspace(nharm1,nharm2,1000);
bf = zeros(length(xharm),1);
for j = 1:length(xharm)
    bf(j) = abs(mean(exp(-1i*theta*xharm(j))));
end
%%
figure
plot(xharm,bf,'-','MarkerSize',3,'MarkerFaceColor','r',...
                'MarkerEdgeColor','r', ...
                'LineWidth',2)
xlim([nharm1,nharm2])
%ylim([0,0.14])
grid
%%
m0 = 9.10938e-31;
c0 = 299792458.0;
e0 = 1.60218e-19;

ibfield2 = linspace(0.2,0.45,500);
%ibfield2 = 0.478;
gam0   = 322.896;
imagl2 = 0.15;
idril2 = 0.1;

nharm  = 10.34;
ks = 2.0*pi/2400e-9;

theta2 = asin(imagl2./(sqrt(gam0^2-1)*m0*c0./ibfield2/e0));
r562   = 2*theta2.^2*(2.0/3.0*imagl2+idril2);

bn = zeros(length(ibfield2),1);
for i = 1:length(ibfield2)
	newphi = ks*(a3(:,1)*c0-r562(i)*(a3(:,2)/gam0-1));
	bn(i)  = abs(mean(exp(-1i*newphi*nharm)));
end
max(bn);
r562opt=r562(bn==max(bn));
%%
figure(7)
plot(r562*1e3,bn,'r-','LineWidth',2)
xlabel('R_{56}^2 [mm]')
ylabel('bf')
figure(8)
plot(a3(:,1)*c0-r562opt*(a3(:,2)/gam0-1),a3(:,2),...
    '.','MarkerSize',1)
xlabel('s [\lambda_s]')
ylabel('\gamma')