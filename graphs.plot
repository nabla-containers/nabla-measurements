# Copyright (c) 2018 Contributors as noted in the AUTHORS file
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose with or without fee is hereby granted, provided
# that the above copyright notice and this permission notice appear
# in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
# OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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
set style line 4 lt 1 pt 4 lc rgb '#000000'

set boxwidth .1
set yrange [0:800]
set xrange [-.5:*]
set xtics ("node-express" 0, "redis-test" 1, "python-tornado" 2)
set style fill solid 1 border lc rgb '#000000'

#'results/summary-ftrace-runsc.dat' using ($0-.1):6 with boxes title "gvisor" lc rgb "#fc8d59"

set output 'graph-functions.png'
set ylabel "Unique kernel functions accessed"
plot \
'results/summary-ftrace-runc.dat' using ($0-.2):6 with boxes title "docker" lc rgb "#d73027", \
'results/summary-ftrace-runc.dat' using ($0-.2):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-ftrace-runsc.dat' using ($0-.1):6 with boxes title "gvisor(ptrace) / gvisor(kvm)" lc rgb "#fee090", \
'results/summary-ftrace-runsc.dat' using ($0-.1):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-ftrace-runsck.dat' using ($0):6 with boxes notitle lc rgb "#fee090", \
'results/summary-ftrace-runsck.dat' using ($0):6 with boxes notitle fillstyle pattern 4 transparent, \
'results/summary-ftrace-runsck.dat' using ($0):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-ftrace-kata.dat' using ($0+.1):6 with boxes title "kata(QEMU) / kata(firecracker)" lc rgb "#e0f3f8", \
'results/summary-ftrace-kata.dat' using ($0+.1):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-ftrace-katafc.dat' using ($0+.2):6 with boxes notitle lc rgb "#e0f3f8", \
'results/summary-ftrace-katafc.dat' using ($0+.2):6 with boxes notitle fillstyle pattern 4 transparent, \
'results/summary-ftrace-katafc.dat' using ($0+.2):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-ftrace-runnc.dat' using ($0+.3):6 with boxes title "nabla" lc rgb "#91bfdb", \
'results/summary-ftrace-runnc.dat' using ($0+.3):6:($6-$7):($6+$7) with errorbars ls 3 notitle

set output 'graph-syscalls.png'
set ylabel "Unique syscalls accessed"
plot \
'results/summary-syscalls-runc.dat' using ($0-.2):6 with boxes title "docker" lc rgb "#d73027", \
'results/summary-syscalls-runc.dat' using ($0-.2):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-syscalls-runsc.dat' using ($0-.1):6 with boxes title "gvisor" lc rgb "#fc8d59", \
'results/summary-syscalls-runsc.dat' using ($0-.1):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-syscalls-runsck.dat' using ($0):6 with boxes title "gvisor-kvm" lc rgb "#fee090", \
'results/summary-syscalls-runsck.dat' using ($0):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-syscalls-kata.dat' using ($0+.1):6 with boxes title "kata" lc rgb "#e0f3f8", \
'results/summary-syscalls-kata.dat' using ($0+.1):6:($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-syscalls-runnc.dat' using ($0+.2):6 with boxes title "nabla" lc rgb "#91bfdb", \
'results/summary-syscalls-runnc.dat' using ($0+.2):6:($6-$7):($6+$7) with errorbars ls 3 notitle

set yrange [0:1000]
set output 'graph-complexity.png'
set ylabel "Sum of complexity metric"
plot \
'results/summary-complexity-list-runc.dat' using ($0-.2):($6) with boxes title "docker" lc rgb "#d73027", \
'results/summary-complexity-list-runc.dat' using ($0-.2):($6):($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-complexity-list-runsc.dat' using ($0-.1):($6) with boxes title "gvisor(ptrace) / gvisor(kvm)" lc rgb "#fee090", \
'results/summary-complexity-list-runsc.dat' using ($0-.1):($6):($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-complexity-list-runsck.dat' using ($0):($6) with boxes notitle lc rgb "#fee090", \
'results/summary-complexity-list-runsck.dat' using ($0):($6) with boxes notitle fillstyle pattern 4 transparent, \
'results/summary-complexity-list-runsck.dat' using ($0):($6):($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-complexity-list-kata.dat' using ($0+.1):($6) with boxes title "kata(QEMU) / kata(firecracker)" lc rgb "#e0f3f8", \
'results/summary-complexity-list-kata.dat' using ($0+.1):($6):($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-complexity-list-katafc.dat' using ($0+.2):($6) with boxes notitle lc rgb "#e0f3f8", \
'results/summary-complexity-list-katafc.dat' using ($0+.2):($6) with boxes notitle fillstyle pattern 4 transparent, \
'results/summary-complexity-list-katafc.dat' using ($0+.2):($6):($6-$7):($6+$7) with errorbars ls 3 notitle, \
'results/summary-complexity-list-runnc.dat' using ($0+.3):($6) with boxes title "nabla" lc rgb "#91bfdb", \
'results/summary-complexity-list-runnc.dat' using ($0+.3):($6):($6-$7):($6+$7) with errorbars ls 3 notitle
