using Aqua
using DecisionTree: Leaf, Node
using Documenter
using HerbBenchmarks
using RefactoringExperiments
using Test
using JSON
using Clingo_jll

@testset "HerbSearch.jl" verbose = true begin
    include("test_aulile_compression.jl")
    include("test_dream_coder.jl")

end