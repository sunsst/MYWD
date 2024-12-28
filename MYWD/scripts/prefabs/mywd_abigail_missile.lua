local spawn_radius = 2

local function onhit(inst, attacker, target)
    c_announce("导弹命中") --mywd
    inst:Remove()
end
local function onmiss(inst, attacker, target)
    c_announce("导弹未命中") --mywd
    inst:Remove()
end
local function Fire(self, abigail, target)
    if not abigail then
        c_announce("导弹发射没有主人") --mywd
        return
    end
    if not target then
        c_announce("导弹发射没有目标") --mywd
        return
    end

    local x, z, y = abigail.Transform:GetWorldPosition()
    local r = math.random() - 0.5
    x = r * spawn_radius + x
    r = math.random() - 0.5
    y = r * spawn_radius + y
    self.Transform:SetPosition(x, z, y)
    self.components.projectile:Throw(abigail, target, abigail)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 1, 0)

    inst.AnimState:SetBank("mywd_abigail_missile")
    inst.AnimState:SetBuild("mywd_abigail_missile")
    inst.AnimState:PlayAnimation("idle")



    inst:AddTag("weapon")
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MYWD.ABIGAIL_MOON_MISSILE_DAMAGE)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.MYWD.ABIGAIL_MOON_MISSILE_SPEED)
    inst.components.projectile:SetOnHitFn(onhit)
    inst.components.projectile:SetOnMissFn(onmiss)

    inst.Fire = Fire
    return inst
end


return Prefab("mywd_abigail_missile", fn, {
    Asset("ANIM", "anim/mywd_abigail_missile.zip")
})
