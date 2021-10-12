for t in 1 2 3 4 5 6 7 8 9 10
do
    likwid-pin -s 0xfffffffffffff801 -c S0:0-$((t-1)) julia --project=../.. -t$((t)) --math-mode=fast manual.jl | grep SDax;
done