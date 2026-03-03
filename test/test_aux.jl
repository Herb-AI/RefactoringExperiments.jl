include("../src/aulile_auxiliary_functions.jl")

@test pixel_equal(HerbBenchmarks.Pixels_2020.PixelState([true true; true true], (1, 1)), HerbBenchmarks.Pixels_2020.PixelState([true true; true true], (2, 2)))
@test strings_equal(HerbBenchmarks.String_transformations_2020.StringState("Hello, World", 1), HerbBenchmarks.String_transformations_2020.StringState("Hello, World", 3))
@test robot_equal(HerbBenchmarks.Robots_2020.RobotState(1, 2, 2, 2, 2, 1), HerbBenchmarks.Robots_2020.RobotState(1, 2, 2, 2, 2, 1))
