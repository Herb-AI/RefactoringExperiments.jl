using JSON, Clingo_jll
using HerbCore, HerbGrammar, HerbSearch


grammar = @csgrammar begin
    Int = 1
    Int = Int + Int
    Int = Int * Int
    Int = Int - Int
    Int = Int / Int
    Int = 1 + Num
    Int = 1 + Int
    Num = 3
    Num = 4
    Num = 5
    Int = Num
end


# 1 + (1 + (Num 3))
# 1 + (1 + (Num 4))
# 1 + (1 + (Num 5))
ast1 = RuleNode(2, [RuleNode(1), RuleNode(6, [RuleNode(8)])])
ast2 = RuleNode(2, [RuleNode(1), RuleNode(6, [RuleNode(9)])])
ast3 = RuleNode(2, [RuleNode(1), RuleNode(6, [RuleNode(10)])])
useful_asts = [ast1, ast2, ast3]
new_grammar, _ = refactor_grammar(useful_asts, grammar, 1, 10, 60)
@show new_grammar