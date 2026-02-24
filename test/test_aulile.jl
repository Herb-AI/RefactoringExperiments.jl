@testset "Aulile No Compression" begin
    experiment_main("karel", 15, 10, 100, what_to_run="regular+aulile_edit_distance")
    experiment_main("karel", 15, 10, 250, what_to_run="regular+aulile_edit_distance")
    experiment_main("karel", 15, 10, 500, what_to_run="regular+aulile_edit_distance")
    experiment_main("karel", 15, 10, 1000, what_to_run="regular+aulile_edit_distance")
end