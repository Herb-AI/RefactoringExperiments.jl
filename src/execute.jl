if length(ARGS) >= 5
    experiment_main(ARGS[1], parse(Int, ARGS[2]), parse(Int, ARGS[3]), parse(Int, ARGS[4]),
        what_to_run=ARGS[5])
else
    experiment_main(ARGS[1], parse(Int, ARGS[2]), parse(Int, ARGS[3]), parse(Int, ARGS[4]))
end
