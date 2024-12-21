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





local function post_fn(inst)
    -- 鬼魂的范围攻击组件
    local aura = inst:AddComponent("aura")
    aura.radius = TUNING.MYWD.WENDY_AURA_RADIUS
    aura.tickperiod = TUNING.MYWD.WENDY_AURA_TICKPERIOD
    -- aura.ignoreallies = true
    aura.auratestfn = auratest

    local wdbuf = inst:AddComponent("mywd_wdbuf")

    -- 暗影增伤，如果有旧增伤会保留
    local old_customdamagemultfn = inst.components.combat.customdamagemultfn
    inst.components.combat.customdamagemultfn = function(inst, target)
        return (wdbuf:IsShadowUP() and TUNING.MYWD.WENDY_SHADOW_DAMAGE_MOD or 1) *
            old_customdamagemultfn(inst, target)
    end


    -- 修改温蒂的运动组件拦截暗影buff期间的攻击动作
    local old_pushactionfn = inst.components.locomotor.PushAction
    inst.components.locomotor.PushAction = function(self, bufferedaction, run, try_instant)
        if bufferedaction.action == ACTIONS.ATTACK and wdbuf:IsShadowBuff() then
            return
        else
            old_pushactionfn(self, bufferedaction, run, try_instant)
        end
    end
end

AddPrefabPostInit("wendy", post_fn)
