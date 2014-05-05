% fid   = fopen('/home/tong/work/SIOM-FEL/20140107/SS/optbeta/TDP/seed0.out.dfl','r');
fid   = fopen('/home/tong/work/SIOM-FEL/20140107/SS/optbeta/TDP/seed.in','r');

ncar  = 201;
dgrid = 1e-3;
nslice= 260;
for islice = 1:nslice
    a = fread(fid,ncar*2*ncar,'double');
    realpart = reshape(a(1:2:end),ncar,ncar);
    imagpart = reshape(a(2:2:end),ncar,ncar);
    meshsize = dgrid*2/(ncar-1);
    xArray=((1-ncar)/2:(ncar-1)/2)*meshsize;
    [X,Y] = meshgrid(xArray,xArray);
    if islice == 260
    figure(8)
    contourf(X,Y,realpart.^2+imagpart.^2,100)
    shading flat
    colorbar
    set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('$x\,\mathrm{[mm]}$','Interpreter','LaTeX',...
        'FontName','Times New Roman','FontSize',12)
    ylabel('$y\,\mathrm{[mm]}$','Interpreter','LaTeX',...
        'FontName','Times New Roman','FontSize',12)
    end
    power(islice)= sum(sum(realpart.^2+imagpart.^2));
end
plot(power)