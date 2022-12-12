#!/usr/bin/env sh
#SBATCH -J bwbench
#SBATCH -N 1
#SBATCH -A pc2-mitarbeiter
#SBATCH -p all
#SBATCH -t 00:30:00
#=
ml load lang/JuliaHPC/1.8.3-foss-2022a-CUDA-11.7.0
export JULIA_NUM_THREADS=40
julia --project $(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
exit
# =#

println("Node: ", gethostname(), "\n")

using BandwidthBenchmark
using StatsPlots
using DataFrames
using CSV

bwscaling_memdomain = bwscaling_memory_domains()
CSV.write(joinpath(@__DIR__, "bwscaling_memdomain.csv"), bwscaling_memdomain)
# bwscaling_memdomain = CSV.read(joinpath(@__DIR__, "bwscaling_memdomain.csv"), DataFrame)

function plot_scaling(results, kernel)
    df = subset(results, :Function => x -> x .== kernel)
    @df df plot(:var"# Threads per domain", :var"Rate (MB/s)" ./ 1000,
        group=(:var"# Memory domains"),
        legend=:topleft,
        # title=title,
        xlabel="number of cores per memory domain",
        xticks=0:1:maximum(:var"# Threads per domain"),
        ylabel="Memory Bandwidth [GB/s]",
        marker=:circle,
        markersize=3,
    )
end

for kernel in ("Init", "Copy", "Update", "Triad", "Daxpy", "STriad", "SDaxpy")
    plot_scaling(bwscaling_memdomain, kernel)
    savefig(joinpath(@__DIR__, "bwscaling-memdomain-$(lowercase(kernel)).pdf"))
end
