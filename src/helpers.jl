function print_stats(stats::AulileStats, best_value::Number)
    passed = !isnothing(stats.program) && stats.score <= best_value
    print(Int(passed), ", ", stats.iterations, ", ", stats.enumerations)
    return passed
end

function print_stats(stats::SearchStats, best_value::Number)
    passed = !isnothing(stats.programs) && length(stats.programs) > 0 && stats.score <= best_value
    print(Int(passed), ", ", 1, ", ", stats.enumerations)
    return passed
end

function run_benchmark_comparison(
    benchmark_name,
    init_grammar::AbstractGrammar, problems::Vector{Problem},
    interpret::Function, new_rule_symbol::Symbol;
    max_depth::Int, max_iterations::Int, max_enumerations::Int, modes::Vector{AbstractString})

    passed_tests = fill(0, length(modes))

    print("Problem: ")
    for mode in modes
        print(mode, "_solved_flag, ", mode, "_iter, ", mode, "_enums; ")
    end
    println()
    for (i, problem) in enumerate(problems)
        print("Problem ", i, ": ")
        grammar = deepcopy(init_grammar)

        for (mode_idx, mode) in enumerate(modes)
            aux = default_aux
            if mode == "regular"
                opts = SynthOptions(
                    num_returned_programs=1,
                    max_enumerations=max_iterations*max_enumerations,
                    eval_opts=EvaluateOptions(
                    aux=aux,
                    interpret=interpret
                    )
                )
                stats = synth_with_aux(problem, BFSIterator(grammar, :Start, max_depth=max_depth), 
                    grammar, Dict{Int64,AbstractRuleNode}(), typemax(Int), opts=opts)
                best_value = 0
            else
                aux=AUX_FUNCTIONS[benchmark_name][mode]
                opts = AulileOptions(
                    max_iterations=max_iterations,
                    max_depth=max_depth,
                    restart_iterator=true,
                    synth_opts=SynthOptions(
                    num_returned_programs=1,
                    max_enumerations=max_enumerations,
                    eval_opts=EvaluateOptions(
                    aux=aux,
                    interpret=interpret))
                )
                stats = aulile(problem, BFSIterator, grammar, :Start, opts=opts)
                best_value = aux.best_value
            end
            if print_stats(stats, best_value)
                passed_tests[mode_idx] += 1
            end
            print("; ")
        end
        println()
    end
    println()

    for passed in passed_tests
        @assert 0 <= passed <= length(problems)
    end

    return passed_tests
end

function experiment_main(benchmark_name::AbstractString,
    max_depth::Int, max_iterations::Int, max_enumerations::Int;
    what_to_run::AbstractString="regular")

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
            passed_tests_per_mode = run_benchmark_comparison(benchmark_name, init_grammar,
                problems, benchmark.interpret, new_rule_symbol,
                max_depth=max_depth, max_iterations=max_iterations, max_enumerations=max_enumerations,
                modes=modes)

            println(join(modes, ","))
            for (mode_idx, passed_tests) in enumerate(passed_tests_per_mode)
                print(round(passed_tests / length(problems); digits=2))
                if mode_idx ≠ length(modes)
                    print(",")
                end
            end
            println()
        end
    end
end


function get_benchmark(benchmark_name::String)
    if benchmark_name == "strings"
        return HerbBenchmarks.String_transformations_2020
    elseif benchmark_name == "robots"
        return Robots_2020
    elseif benchmark_name == "pixels"
        return HerbBenchmarks.Pixels_2020
    elseif benchmark_name == "bitvectors"
        return HerbBenchmarks.PBE_BV_Track_2018
    elseif benchmark_name == "karel"
        return HerbBenchmarks.Karel_2018
    else
        return HerbBenchmarks.String_transformations_2020
    end
end

function get_start_symbol(benchmark_name::String)
    if benchmark_name == "karel"
        return :Action
    elseif benchmark_name == "bitvectors"
        return :Start
    else
        return :Operation
    end
end

function parse_and_check_modes(what_to_run::AbstractString, benchmark_name::AbstractString)::Vector{AbstractString}
    modes = split(lowercase(what_to_run), "+")

    if !haskey(AUX_FUNCTIONS, benchmark_name)
        available_benchmarks = join(keys(AUX_FUNCTIONS), ", ")
        error("Unsupported benchmark '$benchmark_name'. Available benchmarks: $available_benchmarks")
    end

    inner_dict = AUX_FUNCTIONS[benchmark_name]
    for mode in modes
        if mode == "regular"
            continue
        end
        if !haskey(inner_dict, mode)
            available_modes = join(keys(inner_dict), ", ")
            error("Unknown aulile mode '$mode' for benchmark '$benchmark_name'. Available modes: $available_modes")
        end
    end

    return modes
end
