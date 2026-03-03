@testset "test_dream_coder.jl" begin
    # run_dream_coder_experiment("karel", 15, 10, 100, what_to_run="regular+aulile_edit_distance", use_compression=false)
    run_dream_coder_experiment("karel", 15, 10000, aux_tag="regular+aulile_edit_distance", use_compression=true, compression_timeout=120)
end