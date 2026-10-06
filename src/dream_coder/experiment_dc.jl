# struct CompressionSettings
#     compress::Bool
#     k::Int
#     time_limit::Int
#     max_compression_nodes::Int
# end



function dream_coder_experiments(benchmark_name::AbstractString,
    init_grammar::AbstractGrammar,
    problems::AbstractVector{Problem},
    interpret::Function; max_iterations::Int,
    mode::AbstractString,
    writer::Writer,
    do_compression::Bool=false,
    compression_k::Int=1,
    compression_timeout::Int=120,
    max_compression_nodes::Int=10,
    max_number_of_attempts::Int=5)

    small_cost = 1.0
    isprobabilistic(init_grammar) || init_probabilities!(init_grammar)
    for index in eachindex(init_grammar.log_probabilities)
        init_grammar.log_probabilities[index] = small_cost
    end
    actual_start = get_actual_start(init_grammar)
    aux = get(AUX_FUNCTIONS[benchmark_name], mode, default_aux)
    opts = SynthOptions(
        num_returned_programs=1,
        max_enumerations=max_iterations,
        eval_opts=EvaluateOptions(aux=aux, interpret=interpret))

    best_kept_programs = RuleNode[]
    grammar = deepcopy(init_grammar)
    new_rules_decoding = Dict{Int, AbstractRuleNode}()
    unsolved_problems = collect(problems)

    for attempt in 1:max_number_of_attempts
        isempty(unsolved_problems) && break
        @info "Problems yet to solve on attempt $attempt: $(length(unsolved_problems))"
        @info "Best programs for attempt $attempt: $best_kept_programs"

        programs_to_add = best_kept_programs
        if do_compression && length(best_kept_programs) > 1
            programs_to_add = HerbSearch.compress_with_splitting(best_kept_programs, grammar;
                k=compression_k,
                time_limit_sec=compression_timeout,
                max_compression_nodes=max_compression_nodes)
        end

        for rule in programs_to_add
            rule_type = return_type(grammar, rule)
            new_expr = rulenode2expr(rule, grammar)
            to_add = :($rule_type = $(new_expr))
            previous_rule_count = length(grammar.rules)
            if isprobabilistic(grammar)
                add_rule!(grammar, small_cost, to_add)
            else
                add_rule!(grammar, to_add)
            end
            if length(grammar.rules) > previous_rule_count
                new_rules_decoding[length(grammar.rules)] = rule
            end
        end

        best_kept_programs = RuleNode[]
        next_unsolved_problems = Problem[]
        for (problem_count, problem) in enumerate(unsolved_problems)
            @info "Problem #$problem_count, name: $(problem.name)"

            programs_to_outputs(program) = [interpret(program, grammar, spec, new_rules_decoding) for spec in problem.spec]
            iter = CostBasedBottomUpIterator(
                grammar,
                actual_start;
                current_costs=HerbSearch.get_costs(grammar),
                program_to_outputs=programs_to_outputs)
            synth_stats = synth_with_aux(problem, iter, grammar, typemax(Int);
                new_rules_decoding=new_rules_decoding, opts=opts)

            if synth_stats.score == 0
                push!(best_kept_programs, synth_stats.programs[begin])
            else
                push!(next_unsolved_problems, problem)
            end

            entry = DCEntry(problem_count, synth_stats.score, synth_stats.enumerations, synth_stats.time)
            write_entry(writer, entry, attempt)
        end
        unsolved_problems = next_unsolved_problems
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
    aux_tag::AbstractString="default", max_number_of_attempts::Int, use_compression::Bool, compression_timeout::Int=120, k::Int)

    writer = init_write(benchmark_name, (use_compression, k))

    modes = parse_and_check_modes(aux_tag, benchmark_name)

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
        writer=writer,
        mode=only(modes), max_number_of_attempts=max_number_of_attempts,
        do_compression=use_compression, compression_timeout=compression_timeout,
        compression_k=k)


end
