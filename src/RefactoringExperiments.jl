__precompile__(false)

module RefactoringExperiments


using HerbCore
using HerbSearch
using HerbGrammar
using HerbConstraints
using HerbSpecification

using Dates

include("herb_core_patches.jl")

include("aulile_auxiliary_functions.jl")
include("helpers.jl")
include("dream_coder_experiments.jl")

export
    experiment_main,
    run_benchmark,
    run_benchmark_comparison,
    print_stats,
    get_benchmark,
    get_start_symbol,
    parse_and_check_modes,
    run_dream_coder_experiment
end