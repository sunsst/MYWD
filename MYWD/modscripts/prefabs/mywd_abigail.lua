local function post_fn(inst)
    -- inst.AnimState:SetBank("yc")
    -- inst.AnimState:SetBuild("mywd_abigail")
    inst.AnimState:PlayAnimation("idle", true)
end


AddPrefabPostInit("abigail", post_fn)
