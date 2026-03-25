function print_stats(stats::AulileStats, best_value::Number)
    passed = !isnothing(stats.program) && stats.score <= best_value
    print(Int(passed), ", ", stats.iterations, ", ", stats.enumerations, "; ")
    return passed
end

function print_stats(stats::SearchStats, best_value::Number)
    passed = !isnothing(stats.programs) && length(stats.programs) > 0 && stats.score <= best_value
    print(Int(passed), ", ", 1, ", ", stats.enumerations, "; ")
    return passed
end

function parse_and_check_modes(what_to_run::AbstractString, benchmark_name::AbstractString)::Vector{AbstractString}
    modes = split(lowercase(what_to_run), "+")

    haskey(AUX_FUNCTIONS, benchmark_name) || error("Benchmark $benchmark_name does not have an aux function." +
                                                   " Available benchmarks: $available_benchmarks")

    inner_dict = AUX_FUNCTIONS[benchmark_name]
    for mode in modes
        mode == "regular" && continue
        if !haskey(inner_dict, mode)
            available_modes = join(keys(inner_dict), ", ")
            error("Unknown aulile mode $mode for benchmark $benchmark_name. Available modes: $available_modes")
        end
    end
    return modes
end


function run_benchmark_comparison(
    benchmark_name,
    init_grammar::AbstractGrammar, problems::Vector{Problem},
    interpret::Function, new_rule_symbol::Symbol;
    max_depth::Int, max_iterations::Int, max_enumerations::Int, modes::Vector{AbstractString})

    print(new_rule_symbol)
    passed_tests::Dict{String,Int} = Dict{String,Int}()

    print("Problem: ")
    for mode in modes
        print(mode, "_solved_flag, ", mode, "_iter, ", mode, "_enums; ")
        passed_tests[mode] = 0
        if mode != "regular"
            mode = mode * "+compression"
            print(mode, "_solved_flag, ", mode, "_iter, ", mode, "_enums; ")
            passed_tests[mode] = 0
        end
    end
    println()

    for (i, problem) in enumerate(problems)
        print("Problem ", i, ": ")
        grammar = deepcopy(init_grammar)

        for mode in modes
            if mode == "regular"
                opts = SynthOptions(
                    num_returned_programs=1,
                    max_enumerations=max_iterations * max_enumerations,
                    eval_opts=EvaluateOptions(
                        aux=default_aux,
                        interpret=interpret
                    )
                )
                stats = synth_with_aux(problem, BFSIterator(grammar, new_rule_symbol; max_depth),
                    grammar, typemax(Int); opts=opts)
                passed_tests[mode] += print_stats(stats, 0)
            else
                aux = AUX_FUNCTIONS[benchmark_name][mode]
                base_synth_opts = SynthOptions(;
                    num_returned_programs=5,
                    max_enumerations,
                    skip_old_programs=false,
                    eval_opts=EvaluateOptions(; aux, interpret)
                )

                # Without compression
                opts = AulileOptions(; max_iterations, max_depth, synth_opts=base_synth_opts)
                stats = aulile(problem, BFSIterator, grammar, new_rule_symbol; opts)
                passed_tests[mode] += print_stats(stats, aux.best_value)

                # With compression
                compressed_opts = AulileOptions(; max_iterations, max_depth,
                    compression=HerbSearch.compress_with_splitting, synth_opts=base_synth_opts)
                compressed_stats = aulile(problem, BFSIterator, grammar, new_rule_symbol; opts=compressed_opts)
                passed_tests["$mode+compression"] += print_stats(compressed_stats, aux.best_value)
            end
        end
        println()
    end
    println()

    for passed in values(passed_tests)
        @assert 0 <= passed <= length(problems)
    end

    return passed_tests
end

function experiment_main(benchmark_name::AbstractString,
    max_depth::Int, max_iterations::Int, max_enumerations::Int;
    what_to_run::AbstractString="regular")

    modes = parse_and_check_modes(what_to_run, benchmark_name)
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")

    res_path = joinpath(pkgdir(@__MODULE__), "experiments", "aulile", "comparison_results")
    mkpath(res_path)
    res_file_name = "$(benchmark_name)_$(max_depth)_$(max_iterations)_$(max_enumerations)_$(timestamp).txt"
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

            passed_tests_per_mode = run_benchmark_comparison(benchmark_name, init_grammar,
                problems, benchmark.interpret, :Start;
                max_depth, max_iterations, max_enumerations, modes)

            for (mode_idx, mode) in enumerate(modes)
                print(mode)
                mode != "regular" && print(",$mode+compression")
                mode_idx != length(modes) && print(",")
            end
            println()

            for (mode_idx, mode) in enumerate(modes)
                print(round(passed_tests_per_mode[mode] / length(problems); digits=2))
                mode != "regular" && print(",", round(passed_tests_per_mode["$mode+compression"] / length(problems); digits=2))
                mode_idx != length(modes) && print(",")
            end
            println()
        end
    end
end