local my_abigail = require("prefabs/abigail")
local old_fn = my_abigail.fn



my_abigail.fn = function()
    local inst = old_fn()

    -- 不许阿比盖尔生气
    inst.BecomeAggressive = function() end

    -- inst.AnimState:SetBuild("mywd_abigail")

    inst.AnimState:SetBuild("yc")

    return inst
end




return my_abigail
