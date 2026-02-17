using HerbCore, HerbSearch, HerbGrammar, HerbBenchmarks, HerbSpecification
using Clingo_jll, JSON

include("experiment.jl")

benchmark = HerbBenchmarks.Karel_2018

aulile_with_compression(
    benchmark_name = "Karel",
    problems = benchmark.get_all_problems(),
    grammar  = benchmark.grammar_karel,
    starting_symbol = :Block,
    aulile_parameters = AulileOptions(
            max_iterations        = 5,
            max_depth             = 10,
            restart_iterator      = true,
        compression = (ps, g; k) -> HerbSearch.compress_to_expressions(ps, g;
            k                     = 1,
            max_compression_nodes = 10, 
            time_limit_sec        = 120),
        synth_opts = SynthOptions(
            num_returned_programs = 10,
            max_enumerations      = typemax(Int),
            max_time              = 10,
            print_debug           = false,
            eval_opts = EvaluateOptions(
            aux                     = default_aux,
            interpret               = benchmark.interpret,
            allow_evaluation_errors = false
            ),
        ),
    ),
)