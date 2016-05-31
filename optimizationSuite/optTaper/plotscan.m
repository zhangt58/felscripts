%% MATLAB script for two-dimensional plot
% Author: Tong Zhang
% E-mail: tzhang@sinap.ac.cn
% Updated Time: 2014-05-15, 09:31 CST

dimx = 49;
dimy = 180;
a = load('../opt2/scanTaper.49462.dat');
tzpo = reshape(a(:,1),dimx,dimy);
tper = reshape(a(:,2),dimx,dimy)*100;
scanp = reshape(a(:,4),dimx,dimy);
[C1,h1] = contourf(tzpo,tper,scanp,400);
shading flat
% xlim([10,50])
% ylim([-50,-10])
xlabel('$\mathrm{z\,[m]}$','Interpreter','LaTeX',...
		'FontSize',12,'FontName','Times New Roman',...
		'FontWeight','b','Color','black')
ylabel('$\mathrm{Taper\,[\%]}$','Interpreter','LaTeX',...
		'FontSize',12,'FontName','Times New Roman',...
		'FontWeight','b','Color','black')
h1 = colorbar;
h2 = gca;
set(h1,'FontSize',12,'FontName','Times New Roman','FontWeight','l')
set(h2,'FontSize',12,'FontName','Times New Roman','FontWeight','l')
