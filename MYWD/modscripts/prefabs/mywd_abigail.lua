local function SetMaxHealth(inst)
    local health = inst.components.health
    if health then
        if health:IsDead() then
            health.maxhealth = inst.base_max_health + inst.bonus_max_health
        else
            local health_percent = health:GetPercent()
            health:SetMaxHealth(inst.base_max_health + inst.bonus_max_health)
            health:SetPercent(health_percent, true)
        end

        if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
            inst._playerlink.components.pethealthbar:SetMaxHealth(health.maxhealth)
        end
    end
end


local function post_fn(inst)
    -- inst.AnimState:SetBank("yc")
    -- inst.AnimState:SetBuild("mywd_abigail")
    -- inst.AnimState:PlayAnimation("idle", true)
end


-- AddPrefabPostInit("abigail", post_fn)
