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
            return false
        else
            return old_changebehaviourfn(self)
        end
    end
    inst.components.ghostlybond.changebehaviourfn = new_changebehaviourfn

    -- 假死期间禁止召回
    local old_recalfn = inst.components.ghostlybond.Recall
    local new_recallfn = function(self, was_killed)
        if wdbuf:IsCantInLimboShadow() then
            return false
        elseif wdbuf:ToNormalOK() then
            wdbuf:ToNormal()
            return false
        else
            return old_recalfn(self, was_killed)
        end
    end
    inst.components.ghostlybond.Recall = new_recallfn
end

AddPrefabPostInit("wendy", post_fn)


-- 有更好的选择，但保留一下这部分代码
-- local function stop_wendy_shadow_atk(sg)
--     -- 拦截暗影状态下的温蒂攻击
--     sg.actionhandlers[ACTIONS.ATTACK].condition = function(inst)
--         c_announce(not (inst and inst.prefab == "wendy" and inst.components.mywd_wdbuf:IsShadowBuff()))
--         return not (inst and inst.prefab == "wendy" and inst.components.mywd_wdbuf:IsShadowBuff())
--     end
-- end
-- AddStategraphPostInit("wilson", stop_wendy_shadow_atk)
-- AddStategraphPostInit("wilson_client", stop_wendy_shadow_atk)
