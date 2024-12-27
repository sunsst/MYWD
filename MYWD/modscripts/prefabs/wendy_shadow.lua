local function auratest(inst, target, can_initiate)
    -- 不要伤害不打架的人
    if not target.components.combat then
        return false
    end
    -- 不要伤害自己的阿比盖尔
    if inst.components.ghostlybond and inst.components.ghostlybond.ghost == target then
        return false
    end
    return true
end


local function prefab_post_fn(inst)
    -- 鬼魂的范围攻击组件
    local aura = inst:AddComponent("aura")
    aura.radius = TUNING.MYWD.WENDY_AURA_RADIUS
    aura.tickperiod = TUNING.MYWD.WENDY_AURA_TICKPERIOD
    -- aura.ignoreallies = true
    aura.auratestfn = auratest

    -- 辅组条件判断组件
    local wdbuf = inst:AddComponent("mywd_wdbuf")


    -- 修改温蒂的运动组件，AOE期间禁止攻击
    local old_pushactionfn = inst.components.locomotor.PushAction
    local function new_pushactionfn(self, bufferedaction, run, try_instant)
        if not (bufferedaction.action == ACTIONS.ATTACK and wdbuf:IsWendyAOEShadow()) then
            old_pushactionfn(self, bufferedaction, run, try_instant)
        end
    end
    inst.components.locomotor.PushAction = new_pushactionfn


    -- 修改温蒂自定义伤害函数，添加暗影buff增伤，保留原有增伤
    local old_customdamagemultfn = inst.components.combat.customdamagemultfn
    local new_customdamagemultfn = function(inst, target)
        return (wdbuf:IsWendyDamageUPShadow() and TUNING.MYWD.WENDY_SHADOW_DAMAGE_MOD or 1) *
            old_customdamagemultfn(inst, target)
    end
    inst.components.combat.customdamagemultfn = new_customdamagemultfn

    -- 禁止切换阿比状态
    local old_changebehaviourfn = inst.components.ghostlybond.ChangeBehaviour
    local new_changebehaviourfn = function(self)
        if wdbuf:IsCantDefensiveShadow() then
            c_announce("拦截温蒂切换阿比状态") --mywd
            return false
        else
            c_announce("正常温蒂切换阿比状态") --mywd
            return old_changebehaviourfn(self)
        end
    end
    inst.components.ghostlybond.ChangeBehaviour = new_changebehaviourfn

    -- 假死期间禁止召回
    local old_recalfn = inst.components.ghostlybond.Recall
    local new_recallfn = function(self, was_killed)
        if wdbuf:IsCantInLimboShadow() then
            c_announce("拦截温蒂召唤阿比") --mywd
            return false
        elseif wdbuf:IsFeignDeadShadow() then
            c_announce("阿比假死状态回收") --mywd
            wdbuf:ToNormalShadow()
            return old_recalfn(self, was_killed)
        else
            c_announce("正常温蒂收回阿比") --mywd
            return old_recalfn(self, was_killed)
        end
    end
    inst.components.ghostlybond.Recall = new_recallfn
end



local function modify()
    AddPrefabPostInit("wendy", prefab_post_fn)
end
modify()
