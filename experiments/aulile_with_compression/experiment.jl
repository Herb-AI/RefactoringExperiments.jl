#=========================== 
    Single problem
============================

Given are:
- Problem specification and grammar
- Amount of programs returned by Aulile and compressed
- Aulile parameters
- Compression parameters

The baseline is default Aulile, which goes as follows:
1. Run bottom-up search for a certain amount of time/programs
2. Using an auxilary function find the best program
3. Add this program to the grammar
4. Repeat from 1.

The method used in the experiment alters Aulile:
1. Run bottom-up search for a certain amount of time/programs
2. Using an auxilary function find the N best programs              (edit: find N best)
3. Compress the N best program into a single one                    (edit: compress N best into one)
4. Add this program to the grammar
5. Repeat from 1.

The following metrics are returned:
- Percentage of example solved
- Amount of iterations
- Execution time
- Memory usage?
- Grammar extensions

=#

function aulile_with_compression(;
    problem::Problem, 
    grammar::AbstractGrammar, 
    starting_symbol::Symbol,
    amount_of_programs_compressed::Int,
    compression_parameters::CompressionParameters,
    aulile_parameters::AulileParameters,
)

    base_iterator = BottomUpIterator(grammar, starting_symbol)

    compression(programs::Vector{AbstractRuleNode}) = refactor_grammar(programs, grammar, 
        k                     = compression_parameters.k,
        max_compression_nodes = compression_parameters.max_compression_nodes, 
        time_limit_sec        = compression_parameters.time_limit_sec, 
        ASP_PATH              = compression_parameters.ASP_PATH)

    # TODO run Aulile

    return nothing
end

function aulile_with_compression(;
    benchmark_name::String,
    problem_grammar_pairs::Vector{},
    starting_symbol::Symbol,
    amount_of_programs_compressed::Int,
    compression_parameters::CompressionParameters,
    aulile_parameters::AulileParameters,
)
    @show benchmark_name
    # TODO: store results somewhere    

    for (problem, grammar) in problem_grammar_pairs
        @show aulile_with_compression(
            problem = problem,
            grammar = grammar,
            starting_symbol = starting_symbol,
            amount_of_programs_compressed = amount_of_programs_compressed,
            compression_parameters = compression_parameters,
            aulile_parameters = aulile_parameters,
        )

        # TODO save these
    end

end