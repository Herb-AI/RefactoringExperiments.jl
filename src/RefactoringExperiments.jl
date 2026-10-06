__precompile__(false)

module RefactoringExperiments


using HerbCore
using HerbSearch
using HerbGrammar
using HerbConstraints
using HerbSpecification
using Clingo_jll
using JSON
using HerbBenchmarks

using Dates

include("res_writer.jl")

include("herb_patches.jl")
include("herb_core_patches.jl")

include("helpers.jl")
include("aulile_auxiliary_functions.jl")

include("aulile_with_compression/experiment_awc.jl")
include("dream_coder/experiment_dc.jl")

export
    get_benchmark,
    run_aulile_compression_experiment,
    run_dream_coder_experiment
end
