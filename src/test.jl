using HerbCore, HerbSearch, HerbConstraints, HerbGrammar

grammar = @cfgrammar begin
    Int = 1
    Int = 2
    Int = - Int
    Int = Int + Int
end

#=

1 + (1, 2)          4 { 1 , [1,1,0,0] }
1 + 1
1 + 2

1 + Int             4 { 1 , [1,1,1,1] }

=#



hole_domain = Bool[0, 1, 1, 0]


for (i, d) in enumerate(hole_domain)
    !d && continue
    @show i
end