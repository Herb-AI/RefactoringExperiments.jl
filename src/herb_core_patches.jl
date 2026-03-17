import HerbCore
import .HerbCore: get_rule

function HerbCore.get_rule(hole::AbstractHole)
    # now it's a bit risky cause it can omit something, but grammar is not a part of this call so I can't do it otherwise.
    return findfirst(hole.domain)
end