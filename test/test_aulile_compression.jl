@testset "test_aulile_compression" begin
    run_aulile_compression_experiment("karel", 15, 10, 100, what_to_run="regular+default+aulile_edit_distance")
    run_aulile_compression_experiment("karel", 15, 10, 250, what_to_run="regular+default+aulile_edit_distance")
    run_aulile_compression_experiment("karel", 15, 10, 500, what_to_run="regular+default+aulile_edit_distance")
    run_aulile_compression_experiment("karel", 15, 10, 1000, what_to_run="regular+default+aulile_edit_distance")
end