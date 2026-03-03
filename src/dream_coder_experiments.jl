# struct CompressionSettings
#     compress::Bool
#     k::Int
#     time_limit::Int
#     max_compression_nodes::Int
# end

function dream_coder_experiments(benchmark_name,
    init_grammar::AbstractGrammar, 
    problems::AbstractVector{Problem},
    interpret::Function; max_iterations::Int,
    mode,
    do_compression = false,
    compression_k::Int=1,       # repeats default Compression settings
    compression_timeout::Int=120,
    max_compression_nodes::Int=10,
    max_number_of_attempts::Int=5
    )
    println("Benchmark: $(benchmark_name)")
    if do_compression
        println("Yes compression!!")
    else
        println("No compression!!")
    end
    SMALL_COST = 0.5
    isprobabilistic(init_grammar) || init_probabilities!(init_grammar)
    ACTUAL_START = get_actual_start(init_grammar)
    aux = default_aux
            (mode in keys(AUX_FUNCTIONS[benchmark_name])) && (aux = AUX_FUNCTIONS[benchmark_name][mode])
    opts = SynthOptions(
            num_returned_programs=1,
            max_enumerations=max_iterations, 
            eval_opts=EvaluateOptions(
                aux=aux,
                interpret=interpret
                )
            )

    best_kept_programs = Vector{RuleNode}()
    grammar = deepcopy(init_grammar) 
    # a dictionary to enable interpretation of new rules.
    new_rules_decoding = Dict{Int, AbstractRuleNode}()
    attempt_counter = 0
    unsolved_problems = Set(problems)
    while !isempty(unsolved_problems) && (attempt_counter < max_number_of_attempts)
        attempt_counter += 1
        @info "Problems yet to solve on attempt $(attempt_counter): $(length(unsolved_problems))\n"
        @info "Best programs for attempt $(attempt_counter): $best_kept_programs\n"
        programs_to_add = best_kept_programs
        if do_compression && length(best_kept_programs) > 1
            # compress programs with the given parameters.
            programs_to_add = HerbSearch.compress_with_splitting(best_kept_programs, grammar;
            k=compression_k, time_limit_sec=compression_timeout, max_compression_nodes=max_compression_nodes)
        end
        # add the new programs to the grammar
        for rule in programs_to_add
            rule_type = return_type(grammar, rule)
            new_expr = rulenode2expr(rule, grammar)
            to_add = :($rule_type = $(new_expr))
            prev_lenght = length(grammar.rules)
            if isprobabilistic(grammar)
                add_rule!(grammar, SMALL_COST, to_add)
            else 
                add_rule!(grammar, to_add)
            end
            # if a rule was added successfully, add it to the encodings dictionary.
            if length(grammar.rules) > prev_lenght
                grammar_size = length(grammar.rules)
                new_rules_decoding[grammar_size] = rule
            end
        end
        # empty the list of best programs -- in this iterations we will be collecting new best programs.
        best_kept_programs = Vector{RuleNode}()
        # try to synthesize a program for all problems that are not solved yet
        for problem in unsolved_problems
            @info "\nProblem #$(problem.name)"
            println("\nProblem #$(problem.name)")            
            # synthesize until solving, or for a limited number of iterations. Then return best programs found so far
            synth_stats = synth_with_aux(problem, BFSIterator(grammar, ACTUAL_START),
                grammar, typemax(Int), new_rules_decoding=new_rules_decoding, opts=opts)
            # synth_stats = synth_with_aux(problem, CostBasedBottomUpIterator(grammar, ACTUAL_START; current_costs=HerbSearch.get_costs(grammar)),
            #     grammar, typemax(Int), new_rules_decoding=new_rules_decoding, opts=opts)
            
            if synth_stats.score == 0
                push!(best_kept_programs, synth_stats.programs[begin])
                delete!(unsolved_problems, problem)
            end
        end
    end
end

function get_actual_start(grammar)
    if grammar.types[1] == :Start
        return grammar.rules[1]
    else
        @error "Where's the start in your grammar?"
    end
end

function run_dream_coder_experiment(benchmark_name::AbstractString, max_iterations::Int;
    aux_tag::AbstractString="number_of_unsolved_examples", max_number_of_attempts::Int, use_compression::Bool, compression_timeout::Int=120)

    modes = parse_and_check_modes(aux_tag, benchmark_name)
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    dir_path = pkgdir(@__MODULE__)
    res_path = joinpath(dir_path, "experiments", "aulile", "comparison_results")
    mkpath(res_path)
    res_file_name = "$(benchmark_name)_$(max_iterations)_$(timestamp).txt"
    res_file_path = joinpath(res_path, res_file_name)

    # open results file and redirect STDIO
    open(res_file_path, "w") do io
        redirect_stdout(io) do
            benchmark = get_benchmark(benchmark_name)
            if benchmark_name == "karel"
                problems = HerbBenchmarks.Karel_2018.get_all_problems()
                init_grammar = HerbBenchmarks.Karel_2018.grammar_karel
            else
                problems = get_all_problems(benchmark)
                init_grammar = get_default_grammar(benchmark)
            end
            dream_coder_experiments(benchmark_name, init_grammar, problems, 
                benchmark.interpret; max_iterations=max_iterations,
                mode=only(modes), max_number_of_attempts=max_number_of_attempts, do_compression=use_compression, compression_timeout=compression_timeout)
        println()
        end
        
    end
end
