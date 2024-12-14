local assets = {
    Asset("ANIM", "anim/abigail_bullet.zip")
}

local function miss(inst)
    print("MYWD_MISS")
    inst:Hide()
    inst._waithit = false
end

local function hit(inst, attacker, target)
    print("MYWD_ONHIT")
    inst:Hide()
    inst._waithit = false

    if target and target.components.health then
        -- 确保目标有 health 组件并应用伤害
        target.components.health:DoDelta(-inst.components.weapon.damage)
    end
end

local function OnThrow(inst)
    print("MYWD_ONTHROW")
    inst:Show()
    inst._waithit = true
end


local function Throw(inst, target)
    if inst._waithit then return end
    inst._waithit = true

    if inst.owner then
        print("MYWD_OWNER")
        inst.Transform:SetPosition(inst.owner.Transform:GetWorldPosition())
    end
    print("MYWD_THROW")
    inst.components.projectile:Throw(inst, target, inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("abigail")
    inst.AnimState:SetBuild("abigail_bullet")
    inst.AnimState:PlayAnimation("bullet")

    MakeInventoryFloatable(inst, "small", 0.05, { 0.75, 0.5, 0.75 })

    if not TheWorld.ismastersim then
        return inst
    end



    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(2)


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MYWD_ABIGAIL_BULLET_DAMAGE)
    inst.components.weapon:SetRange(8, 10)

    inst.owner = nil
    inst._waithit = false

    inst:Hide()
    inst.components.projectile:SetOnHitFn(hit)
    inst.components.projectile:SetOnMissFn(miss)
    inst.components.projectile:SetOnThrownFn(OnThrow)
    inst.Throw = Throw
    return inst
end





return Prefab("abigail_bullet", fn, assets)
