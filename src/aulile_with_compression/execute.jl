using HerbCore, HerbSearch, HerbGrammar, HerbBenchmarks, HerbSpecification
using Clingo_jll, JSON

benchmark = HerbBenchmarks.Karel_2018

aulile_with_compression(
    benchmark_name = "Karel",
    problems = benchmark.get_all_problems(),
    grammar  = benchmark.grammar_karel,
    starting_symbol = :Block,
    aulile_parameters = AulileOptions(
            max_iterations        = 3,
            max_depth             = 4,
            restart_iterator      = true,
        synth_opts = SynthOptions(
            num_returned_programs = 10,
            max_enumerations      = 1000,
            # max_time              = 1,
            print_debug           = false,
            eval_opts = EvaluateOptions(
            aux                     = default_aux,
            interpret               = benchmark.interpret,
            allow_evaluation_errors = false
            ),
        ),
    ),
)