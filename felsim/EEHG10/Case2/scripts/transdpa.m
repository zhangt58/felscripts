#!/usr/bin/octave -qf

args    = argv();
infile  = args{1};
outfile = args{2};
npart   = str2num(args{3});
xlamds  = str2num(args{4});

%fid = fopen(infile);
%a = fread(fid,[npart,6],'double');
%fclose(fid);
a = dlmread(infile);

c0 = 299792458.0;
ks = 2*pi/xlamds;

b = zeros(size(a));
b(:,1) = a(:,2)/ks/c0; 	% t
b(:,2) = a(:,1); 		% p (gamma)
b(:,3) = a(:,3); 		% x
b(:,4) = a(:,4); 		% y
b(:,5) = a(:,5)./a(:,1);% betax
b(:,6) = a(:,6)./a(:,1);% betay

dlmwrite(outfile,b,'delimiter',' ','precision','%.20e')

