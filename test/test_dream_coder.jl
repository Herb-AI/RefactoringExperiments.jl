@testset "test_dream_coder.jl" begin
    run_dream_coder_experiment("karel", 1000, aux_tag="number_of_unsolved_examples",max_number_of_attempts=1, use_compression=false, compression_timeout=120)
    # run_dream_coder_experiment("karel", 1000, aux_tag="number_of_unsolved_examples",max_number_of_attempts=2, use_compression=true, compression_timeout=120)
end