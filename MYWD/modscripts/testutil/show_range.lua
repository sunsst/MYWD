local R = 1896 / 2 / 1024 * 1.7 * 4

function ShowRange(parent, rad, addcolor)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()


    local r = rad / R
    inst.AnimState:SetScale(r, r, r)

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    addcolor = addcolor or {}
    inst.AnimState:SetAddColour(addcolor[1] or 0, addcolor[2] or .2, addcolor[3] or .5, addcolor[4] or 0)


    inst.entity:SetParent(parent.entity)

    parent:ListenForEvent("onremove", function()
        inst:Remove()
    end)
end

local function SetRange()
    AddPrefabPostInit("wendy", function(inst)
        ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_FIND_BUTTERFLY_RADIUS, { 0, 0.2 })
        ShowRange(inst, TUNING.MYWD.WENDY_SUMMON_ABIGAIL_RADIUS, { 0.2, 0.2 })
    end)
    AddPrefabPostInit("abigail", function(inst)
        ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_CATCH_BUTTERFLY_DIST, { 0, 1 })
    end)
end
SetRange()
