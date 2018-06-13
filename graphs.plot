reset
set terminal png
set key top right

set bmargin 5

set style line 81 lt 0  # dashed
set style line 81 lt rgb '#808080'  # grey
#set grid back linestyle 81
set grid ytics back linestyle 81

set style line 1 lt 2
set style line 1 lt rgb '#A00000' ps 1 pt 5 lw 1
set style line 2 lt 1 pt 6 lc rgb '#008000'
set style line 3 lt 1 pt 4 lc rgb '#0000A0'

set boxwidth .2
set yrange [0:*]
set xrange [-.5:*]
set xtics ("node-express" 0, "redis-test" 1)

set output 'graph-functions.png'
set ylabel "Unique kernel functions accessed"
plot \
'results/summary-ftrace-runc.dat' using ($0-.2):6 with boxes ls 3 title "docker" fillstyle solid 1, \
'results/summary-ftrace-runc.dat' using ($0-.2):6:3:4 with errorbars ls 3 notitle, \
'results/summary-ftrace-runsc.dat' using ($0):6 with boxes ls 3 title "gvisor" fillstyle solid .6, \
'results/summary-ftrace-runsc.dat' using ($0):6:3:4 with errorbars ls 3 notitle, \
'results/summary-ftrace-runnc.dat' using ($0+.2):6 with boxes ls 3 title "nabla" fillstyle solid .3, \
'results/summary-ftrace-runnc.dat' using ($0+.2):6:3:4 with errorbars ls 3 notitle


set output 'graph-syscalls.png'
set ylabel "Unique syscalls accessed"
plot \
'results/summary-syscalls-runc.dat' using ($0-.2):6 with boxes ls 3 title "docker" fillstyle solid 1, \
'results/summary-syscalls-runc.dat' using ($0-.2):6:3:4 with errorbars ls 3 notitle, \
'results/summary-syscalls-runsc.dat' using ($0):6 with boxes ls 3 title "gvisor" fillstyle solid .6, \
'results/summary-syscalls-runsc.dat' using ($0):6:3:4 with errorbars ls 3 notitle, \
'results/summary-syscalls-runnc.dat' using ($0+.2):6 with boxes ls 3 title "runnc" fillstyle solid .3, \
'results/summary-syscalls-runnc.dat' using ($0+.2):6:3:4 with errorbars ls 3 notitle

