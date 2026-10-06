struct DCEntry{S<:Real,T<:Real}
    count::Int
    score::S
    iterations::Int
    time::T
end

struct Writer
    fname::String
end

function init_write(benchmark_name::AbstractString, compression::Tuple{Bool,Int})
    do_compression, k = compression
    experiment_mode = do_compression ? "Compression_$k" : "Aulile"
    fname = joinpath(@__DIR__, "..", "experiments", "job_out",
        "DC_$(benchmark_name)_$(experiment_mode).csv")
    mkpath(dirname(fname))
    open(fname, "w") do io
        println(io, "problem_count,score,iterations,time,attempts")
    end
    return Writer(fname)
end

function init_write(benchmark_name::AbstractString, N::Integer, k::Integer, comp_time::Real)
    fname = joinpath(@__DIR__, "..", "experiments", "job_out",
        "AC_$(benchmark_name)_$(N)_$(k)_$(comp_time).csv")
    mkpath(dirname(fname))
    open(fname, "w") do io
        println(io, "problem_count,score,iterations")
    end
    return Writer(fname)
end

function write_entry(writer::Writer, entry::DCEntry, attempts::Integer)
    open(writer.fname, "a") do io
        println(io, entry.count, ',', entry.score, ',', entry.iterations, ',', entry.time, ',', attempts)
    end
end

function write_entry(writer::Writer, count::Integer, score::Real, iterations::Integer)
    open(writer.fname, "a") do io
        println(io, count, ',', score, ',', iterations)
    end
end