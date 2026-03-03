# struct CompressionSettings
#     compress::Bool
#     k::Int
#     time_limit::Int
#     max_compression_nodes::Int
# end

function dream_coder_experiments(benchmark_name,
    init_grammar::AbstractGrammar, 
    problems::AbstractVector{Problem},
    interpret::Function;
    max_depth::Int, max_iterations::Int, 
    max_enumerations::Int, mode,
    do_compression = false,
    compression_k::Int=1,       # repeats default Compression settings
    compression_timeout::Int=60,
    max_compression_nodes::Int=10
    )
    ACTUAL_START = get_actual_start(init_grammar)
    best_kept_programs = Vector{RuleNode}()
    println("Benchmark: $(benchmark_name)")
    if do_compression
        println("Yes compression!!")
    else
        println("No compression!!")
    end
    grammar = deepcopy(init_grammar) 
    for (pid, problem) in enumerate(problems)
        println("\nProblem # $pid")
        aux = default_aux
        (mode in keys(AUX_FUNCTIONS[benchmark_name])) && (aux = AUX_FUNCTIONS[benchmark_name][mode])
        # add best programs from previous iterations to the grammar
        programs_to_add = best_kept_programs
        if do_compression && length(best_kept_programs) > 1
            println("Best programs for iteration $pid\n$best_kept_programs\n")
            # compress programs with the given parameters.
            programs_to_add =  HerbSearch.compress_with_splitting(best_kept_programs, grammar;
            k=compression_k, time_limit_sec=compression_timeout, max_compression_nodes=max_compression_nodes)
        end
        # a dictionary to enable interpretation of new rules.
        new_rules_decoding = Dict{Int, AbstractRuleNode}()
        for rule in programs_to_add
            rule_type = return_type(grammar, rule)
            new_expr = rulenode2expr(rule, grammar)
            to_add = :($rule_type = $(new_expr))
            prev_lenght = length(grammar.rules)
            add_rule!(grammar, to_add)
            if length(grammar.rules) > prev_lenght
                grammar_size = length(grammar.rules)
                new_rules_decoding[grammar_size] = rule
            end
        end
        @info grammar
        # synthesize until solving, or for a limited number of iterations. Then return best programs found so far
        opts = SynthOptions(
        num_returned_programs=1,
        max_enumerations=max_iterations*max_enumerations, 
        eval_opts=EvaluateOptions(
            aux=aux,
            interpret=interpret
            )
        )
        synth_stats = synth_with_aux(problem, BFSIterator(grammar, ACTUAL_START, max_depth=max_depth), 
            grammar, typemax(Int), new_rules_decoding=new_rules_decoding, opts=opts)

        isempty(synth_stats.programs) && @warn "Synthesis did not return any programs for problem $pid."
        # _ = print_stats(synth_stats, aux.best_value)
        append!(best_kept_programs, synth_stats.programs)
    end
end

function get_actual_start(grammar)
    if grammar.types[1] == :Start
        return grammar.rules[1]
    else
        @error "Where's the start in your grammar?"
    end
end

function run_dream_coder_experiment(benchmark_name::AbstractString,
    max_depth::Int, max_iterations::Int, max_enumerations::Int;
    what_to_run::AbstractString="regular", use_compression::Bool, compression_timeout::Int=30)
    modes = parse_and_check_modes(what_to_run, benchmark_name)
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    dir_path = pkgdir(@__MODULE__)
    res_path = joinpath(dir_path, "experiments", "aulile", "comparison_results")
    mkpath(res_path)
    res_file_name = "$(benchmark_name)_$(max_depth)_$(max_iterations)_$(max_enumerations)_$(timestamp).txt"
    res_file_path = joinpath(res_path, res_file_name)

    # open results file and redirect STDIO
    open(res_file_path, "w") do io
        redirect_stdout(io) do
            benchmark = get_benchmark(benchmark_name)
            new_rule_symbol = get_start_symbol(benchmark_name)
            if benchmark_name == "karel"
                problems = HerbBenchmarks.Karel_2018.get_all_problems()
                init_grammar = HerbBenchmarks.Karel_2018.grammar_karel
            else
                problems = get_all_problems(benchmark)
                init_grammar = get_default_grammar(benchmark)
            end
            for mode in modes
                dream_coder_experiments(benchmark_name, init_grammar, problems, 
                 benchmark.interpret;max_depth=max_depth, max_iterations=max_iterations, max_enumerations=max_enumerations,
                 mode=mode, do_compression=use_compression)
            end
        println()
        end
        
    end
end