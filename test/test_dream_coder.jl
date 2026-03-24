@testset "test_dream_coder.jl" begin
    # run_dream_coder_experiment("karel", 1000, aux_tag="default",max_number_of_attempts=1, use_compression=false, compression_timeout=120)
    # run_dream_coder_experiment("karel", 1000, aux_tag="default",max_number_of_attempts=30, use_compression=true, compression_timeout=120)
    run_dream_coder_experiment("strings", 1000, aux_tag="default",max_number_of_attempts=30, use_compression=true, compression_timeout=120)
    # run_dream_coder_experiment("robots", 1000, aux_tag="default",max_number_of_attempts=30, use_compression=true, compression_timeout=120)
    # run_dream_coder_experiment("pixels", 1000, aux_tag="default",max_number_of_attempts=30, use_compression=true, compression_timeout=120)
    # run_dream_coder_experiment("bitvectors", 1000, aux_tag="default",max_number_of_attempts=30, use_compression=true, compression_timeout=120)
end