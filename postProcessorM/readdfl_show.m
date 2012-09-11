%This script is used for showing the field pattern from the field ascfile


%first read the ascfile usually contains three cols, realpart imagpart and field intensity (fldinten)

fldinten = reshape(fldinten,ncar,ncar);
maxinten = max(realpart.^2+imagpart.^2);
fldinten = fldinten./maxinten;
[x, y] = meshgrid(1:ncar, 1:ncar);
%figure(1);
subplot(2,2,1);
surf(x,y,fldinten);
zlabel('Intensity');
shading interp
subplot(4,4,3);
pcolor(x,y,fldinten);
axis off
title('Intensity');
shading interp
%axis([1 ncar 1 ncar -0.1 1]);

realpart1 = reshape(realpart,ncar,ncar);
imagpart1 = reshape(imagpart,ncar,ncar);
%figure(2);
subplot(2,2,3);
surf(x,y,realpart1);
shading interp
zlabel('Realpart');
subplot(4,4,7);
pcolor(x,y,realpart1);
axis off
title('Realpart');
shading interp

%figure(3);
subplot(2,2,4);
surf(x,y,imagpart1);
shading interp
zlabel('Imagpart');
subplot(4,4,8);
pcolor(x,y,imagpart1);
axis off
title('Imagpart');
shading interp
