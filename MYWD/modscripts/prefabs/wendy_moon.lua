local function onhitother(inst, data)
    if not data then return end
    local ab = WD2AB(inst)
    local moonab = AB2Moon(ab)

    if moonab and moonab:IsFire() then
        c_announce("发射导弹") --mywd
        local missile = SpawnPrefab("mywd_abigail_missile")
        missile:Fire(ab, data.target)
        return
    end

    c_announce("未满足导弹发射条件") --mywd
end

local function prefab_post_fn(inst)
    -- 当温蒂攻击别人时生成阿比盖尔的导弹并发射
    inst:ListenForEvent("onhitother", onhitother)
end

--------------------------------------------------------------------------------------------------------------------------------

local function modify()
    AddPrefabPostInit("wendy", prefab_post_fn)
end
modify()
