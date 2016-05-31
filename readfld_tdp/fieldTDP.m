fid = fopen('rad.out.dfl');
lambdas = 358e-9;
ncar   = 151;
dgrid  = 4e-3;
%nslice = 169+199;
nslice = 250;
% meshsize = dgrid*2/(ncar-1);
meshsize = 0.3471e-4;
xArray = ((1-ncar)/2:(ncar-1)/2)*meshsize;
yArray = xArray;

% (realpart1, realpart2, ... (ncar*ncar)
%  imagpart1, imagpart2, ...           ) ... x nslice
dims = [2, ncar*ncar, nslice];
a    = fread(fid,'double');
%%
a    = a(end:-1:end-ncar*ncar*nslice*2+1);
%a    = a(1:ncar*ncar*nslice*2);
rawfields = reshape(a, dims);

intfields = abs(complex(rawfields(1,:,:),rawfields(2,:,:))).^2;

% project all fields into one plane, i.e. sum all slices' fields

% three dims of intfields: dim1, dim2, dim3
% dim1: field realpart and imagpart for each discrete points in xoy plane 
% dim2: all points in xoy plane, ncar*ncar
% dim3: all slices, nslices

projpower = sum(intfields,2); % sum along dim2 to get power along s
projpower = reshape(projpower,nslice,1); % ndim(1,1,nslice) -> nslice x 1

projmode = sum(intfields, 3); % sum along dim3 to get projected transverse mode
projmode = reshape(projmode,ncar,ncar);


efields = complex(rawfields(1,:,:),rawfields(2,:,:));
efields = reshape(efields, ncar, ncar, nslice);
wexy = fftshift(fft2(efields));
intFarField = sum(abs(wexy).^2,3);


xArray=((1-ncar)/2:(ncar-1)/2)*meshsize;

thetaArr = xArray*lambdas/ncar/meshsize^2;

[X, Y] = meshgrid(thetaArr, thetaArr);

%%
figure(1)
contourf(X*1e3,Y*1e3,intFarField',500)
shading flat
colorbar
xlim([-2,2])
ylim([-2,2])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
xlabel('$\theta_x\,\mathrm{[mrad]}$','Interpreter','LaTeX',...
        'FontName','Times New Roman','FontSize',12)
ylabel('$\theta_y\,\mathrm{[mrad]}$','Interpreter','LaTeX',...
        'FontName','Times New Roman','FontSize',12)
%%
figure(2)
surf(X*1e3,Y*1e3,intFarField')
shading flat
colorbar
xlim([-5,5])
ylim([-5,5])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
xlabel('$\theta_x\,\mathrm{[mrad]}$','Interpreter','LaTeX',...
        'FontName','Times New Roman','FontSize',12)
ylabel('$\theta_y\,\mathrm{[mrad]}$','Interpreter','LaTeX',...
        'FontName','Times New Roman','FontSize',12)

%%
% figure(3)
% contourf(X*1e6,Y*1e6,zslp-znslp,500)
% shading flat
% colorbar
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
% xlabel('$\theta_x\,\mathrm{[\mu rad]}$','Interpreter','LaTeX',...
%         'FontName','Times New Roman','FontSize',12)
% ylabel('$\theta_y\,\mathrm{[\mu rad]}$','Interpreter','LaTeX',...
%         'FontName','Times New Roman','FontSize',12)
