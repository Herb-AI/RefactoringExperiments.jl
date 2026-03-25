function get_benchmark(benchmark_name::String)
    if benchmark_name == "strings"
        return HerbBenchmarks.String_transformations_2020
    elseif benchmark_name == "robots"
        return Robots_2020
    elseif benchmark_name == "pixels"
        return HerbBenchmarks.Pixels_2020
    elseif benchmark_name == "bitvectors"
        return HerbBenchmarks.PBE_BV_Track_2018
    elseif benchmark_name == "karel"
        return HerbBenchmarks.Karel_2018
    else
        return error("unknown benchmark name $benchmark_name")
    end
end
