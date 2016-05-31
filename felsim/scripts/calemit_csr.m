%%
% calculate emit, bunching for each slice

nslice = 1204;
enx  = zeros(nslice,1);
eny  = zeros(nslice,1);
bf1  = zeros(nslice,1);
bf3  = zeros(nslice,1);
gam  = zeros(nslice,1);
deg  = zeros(nslice,1);
for i = 1:nslice
	fid = fopen(strcat('./csrslices/slice',num2str(i)));
	a = fread(fid,'double');
	tmp = reshape(a,[length(a)/6,6]);
	gam(i) = mean(tmp(:,1));
	deg(i) = std(tmp(:,1));
	x      = tmp(:,3);
	xprime = tmp(:,5)./tmp(:,1);
	enx(i) =  sqrt(mean(x.^2)*mean(xprime.^2)-mean(x.*xprime)^2)*mean(tmp(:,1));
	y      = tmp(:,4);
	yprime = tmp(:,6)./tmp(:,1);
	eny(i) =  sqrt(mean(y.^2)*mean(yprime.^2)-mean(y.*yprime)^2)*mean(tmp(:,1));
	bf1(i) = abs(mean(exp(-1i*1*tmp(:,2))));
	bf3(i) = abs(mean(exp(-1i*3*tmp(:,2))));
	fclose(fid);
end
figure
plot(1:nslice,enx,1:nslice,eny)
figure
plot(1:nslice,bf1,1:nslice,bf3)
figure
plot(1:nslice,gam)
figure
plot(1:nslice,deg)
dlmwrite('emitnxy_csr.dat',[enx,eny],'delimiter',' ','precision','%.6e')
dlmwrite('bf13_csr.dat',[bf1,bf3],'delimiter',' ','precision','%.6e')
dlmwrite('gam_csr.dat',[gam,deg],'delimiter',' ','precision','%.6e')
