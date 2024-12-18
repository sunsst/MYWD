local R = 1896 / 2 / 1024 * 1.7 * 4

function ShowRange(parent, rad)
    local inst = GLOBAL.CreateEntity()

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
    inst.AnimState:SetOrientation(GLOBAL.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(GLOBAL.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetAddColour(0, .2, .5, 0)

    inst.entity:SetParent(parent.entity)

    parent:ListenForEvent("onremove", function()
        inst:Remove()
    end)
end
