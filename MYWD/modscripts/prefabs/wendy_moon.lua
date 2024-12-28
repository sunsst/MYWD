local function onhitother(inst, data)
    if not data then return end
    local ab = inst.components.ghostlybond.ghost

    if ab and ab.components.mywd_moonab:IsFire() then
        c_announce("发射导弹") --mywd
        local missile = SpawnPrefab("mywd_abigail_missile")

        missile:Fire(ab, data.target)
    else
        c_announce("未满足导弹发射条件") --mywd
    end
end

local function prefab_post_fn(inst)
    inst:ListenForEvent("onhitother", onhitother)
end

local function modify()
    AddPrefabPostInit("wendy", prefab_post_fn)
end
modify()
