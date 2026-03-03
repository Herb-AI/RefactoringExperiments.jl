@testset "test_dream_coder.jl" begin
    run_dream_coder_experiment("karel", 1000, aux_tag="regular",max_number_of_attempts=2, use_compression=true, compression_timeout=120)
end