#set terminal wxt enhanced
set terminal post eps color solid enhanced "Helvetica" 16
set size 1.0,1.0
set size ratio 1
set output 'data.eps'

set isosample 500
set hidden3d
set pm3d map
set palette defined ( 0 '#000090',\
					  1 '#000FFF',\
					  2 '#0090FF',\
					  3 '#0FFFEE',\
					  4 '#90FF70',\
					  5 '#FFEE00',\
					  6 '#FF7000',\
					  7 '#EE0000',\
					  8 '#7F0000')
#set palette gray
#set palette defined (0 "white",0.3 "blue", 1 "red")
#rainbow
#set palette rgbformulae 33,13,10
#set palette rgbformulae 33,12,20

unset key
set border 1+2+4+8 ls 7
#unset border
set xtics -10,2,10 out font "Helvetica,14" nomirror scale 0.3 offset 0,0.5
set ytics -10,2,10 out font "Helvetica,14" nomirror scale 0.3 offset 0.8,0

set format x "%.1f"
set format y "%.1f"

set xlabel "QF [T/m]" font "Helvetica,16" offset 0,1.0
set ylabel "QD [T/m]" font "Helvetica,16" offset 1.5,0

set colorbox
set cbrange [5e6:5e7]
set cbtics 5e6,5e6,5e7 scale 0.5 font "Helvetica, 14"
set format cb "%.1t{/Symbol \264}10^{%L}"

set tmargin 1
set bmargin 1
set lmargin 1
set rmargin 1

set xrange [-10:10]
set yrange [-10:10]

splot 'fmtd' u 1:2:4
