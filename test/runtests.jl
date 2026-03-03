using Aqua
using DecisionTree: Leaf, Node
using Documenter
using HerbConstraints
using HerbCore
using HerbGrammar
using HerbInterpret
using HerbSearch
using HerbSpecification
using HerbBenchmarks
using RefactoringExperiments
using Test
using JSON
using Clingo_jll

@testset "HerbSearch.jl" verbose = true begin
    # include("test_aulile.jl")
    include("test_dream_coder.jl")

end