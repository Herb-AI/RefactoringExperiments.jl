using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Clingo_jll, JSON
using RefactoringExperiments

run_dream_coder_experiment(ARGS[1], 100, ARGS[2], aux_tag="regular+aulile_edit_distance", use_compression=true, compression_timeout=120)

