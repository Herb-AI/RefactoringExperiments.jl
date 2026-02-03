
aulile_with_compression(
    benchmark_name = "String transformations",
    problem_grammar_pairs = get_all_problem_grammar_pairs(HerbBenchmarks.String_transformations_2020),
    starting_symbol = Sequence,
    amount_of_programs_compressed = 10,
    compression_parameters => CompressionParameters(
        k = 1,
        max_compression_nodes = 10,
        time_limit_sec = 120),
    aulile_parameters => AulileParameters(),
)

