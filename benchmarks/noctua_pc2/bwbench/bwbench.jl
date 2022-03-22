#!/usr/bin/env sh
#SBATCH -J bwbench
#SBATCH -N 1
#SBATCH -A pc2-mitarbeiter
#SBATCH -p all
#SBATCH -t 01:30:00
#SBATCH --hint=nomultithread
#=
ml load lang/Julia/1.7.2-linux-x86_64
export JULIA_NUM_THREADS=40
julia --project $(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
exit
# =#

println("Node: ", gethostname(), "\n")

using ThreadPinning
using BandwidthBenchmark
using UnicodePlots

# Compact Pinning
println("----------------- Compact Pinning -----------------")
pinthreads(:compact)
threadinfo(; color=false)
println("Check compact pinning: ", getcpuids(), "\n")


# bwbench(; verbose=true);
println("bwbench():")
bwbench(; verbose=true, write_allocate=true);

println("bwscaling():")
data = bwscaling()
p = lineplot(data[:, 1], data[:, 2], title="Bandwidth Scaling, Compact Pinning", xlabel="# cores", ylabel="MB/s", border=:ascii, canvas=AsciiCanvas)
println(p)

println("flopsscaling():")
data = BandwidthBenchmark.flopsscaling()
p = lineplot(data[:, 1], data[:, 2], title="Flops Scaling, Compact Pinning", xlabel="# cores", ylabel="MFlops/s", border=:ascii, canvas=AsciiCanvas)
println(p)

# Scatter Pinning
println("----------------- Scatter Pinning -----------------")
pinthreads(:scatter)
threadinfo(; color=false)
println("Check scatter pinning: ", getcpuids(), "\n")

# bwbench(; verbose=true);
println("bwbench():")
bwbench(; verbose=true, write_allocate=true);

println("bwscaling():")
data = bwscaling()
p = lineplot(data[:, 1], data[:, 2], title="Bandwidth Scaling, Scattered Pinning", xlabel="# cores", ylabel="MB/s", border=:ascii, canvas=AsciiCanvas)
println(p)

println("flopsscaling():")
data = BandwidthBenchmark.flopsscaling()
p = lineplot(data[:, 1], data[:, 2], title="Flops Scaling, Scattered Pinning", xlabel="# cores", ylabel="MFlops/s", border=:ascii, canvas=AsciiCanvas)
println(p)

