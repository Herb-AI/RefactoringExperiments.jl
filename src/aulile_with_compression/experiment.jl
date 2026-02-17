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

function _aulile_with_compression(;
    problem::Problem, 
    grammar::AbstractGrammar, 
    starting_symbol::Symbol,
    aulile_parameters::AulileOptions,
)
    base_iterator_type = DepthBasedBottomUpIterator

    println("Run Aulile")

    stats = aulile(
        problem,
        base_iterator_type,
        grammar,
        starting_symbol,
        opts=aulile_parameters,
    )

    @show stats

    return nothing
end

function aulile_with_compression(;
    benchmark_name::String,
    problems::Vector{},
    grammar::AbstractGrammar,
    starting_symbol::Symbol,
    aulile_parameters::AulileOptions,
)
    @show benchmark_name
    # TODO: store results somewhere   

    for problem in problems
        @show _aulile_with_compression(
            problem = problem,
            grammar = grammar,
            starting_symbol = starting_symbol,
            aulile_parameters = aulile_parameters,
        )

        # TODO save these
    end

end