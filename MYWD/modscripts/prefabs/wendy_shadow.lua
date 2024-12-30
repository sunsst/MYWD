local function auratest(inst, target, can_initiate)
    -- 不要伤害不打架的人
    if not target.components.combat then
        return false
    end
    -- 不要伤害自己的阿比盖尔
    if WD2AB(inst) == target then
        return false
    end
    return true
end


local function make_customdamagemultfn(old_fn)
    return function(inst, target)
        local sdab = WD2ABShadow(inst)
        local v = old_fn(inst, target)
        return (sdab and sdab:IsWendyDamageUP() and TUNING.MYWD.WENDY_SHADOW_DAMAGE_MOD or 1) * v
    end
end


local function make_PushAction(old_fn)
    return function(self, bufferedaction, run, try_instant)
        local sdab = WD2ABShadow(self.inst)

        if sdab and bufferedaction.action == ACTIONS.ATTACK and sdab:IsCantAttack() then
            -- 拦截攻击动作
            return
        end

        old_fn(self, bufferedaction, run, try_instant)
    end
end

local function make_ChangeBehaviour(old_fn)
    return function(self)
        local ab = WD2AB(self.inst)
        local sdab = AB2Shadow(ab)
        if ab and sdab and sdab:IsCantDefensive() then
            if not ab.is_defensive then
                c_announce("拦截温蒂切换阿比状态") --mywd
                return false
            elseif self.changebehaviourfn then
                c_announce("强制激怒阿比") --mywd
                return self.changebehaviourfn(self.inst, ab)
            else
                c_announce("直接激怒阿比") --mywd
                ab:BecomeDefensive()
                return true
            end
        else
            c_announce("正常温蒂切换阿比状态") --mywd
            return old_fn(self)
        end
    end
end

local function make_Recall(old_fn)
    return function(self, was_killed)
        local sdab = WD2ABShadow(self.inst)
        if sdab then
            if sdab:IsCantInLimbo() then
                c_announce("拦截温蒂召唤阿比") --mywd
                return false
            elseif sdab:IsFeignDead() then
                c_announce("阿比假死状态回收") --mywd
                sdab:ToNormal()
                return old_fn(self, was_killed)
            end
        end

        c_announce("正常温蒂收回阿比") --mywd
        return old_fn(self, was_killed)
    end
end


local function prefab_post_fn(inst)
    -- 鬼魂的范围攻击组件
    local aura = inst:AddComponent("aura")
    aura.radius = TUNING.MYWD.WENDY_AURA_RADIUS
    aura.tickperiod = TUNING.MYWD.WENDY_AURA_TICKPERIOD
    -- aura.ignoreallies = true
    aura.auratestfn = auratest


    -- 修改温蒂的运动组件，AOE期间禁止攻击
    inst.components.locomotor.PushAction = make_PushAction(inst.components.locomotor.PushAction)


    -- 修改温蒂自定义伤害函数，添加暗影buff增伤，保留原有增伤
    inst.components.combat.customdamagemultfn = make_customdamagemultfn(inst.components.combat.customdamagemultfn)

    -- 禁止切换阿比状态
    inst.components.ghostlybond.ChangeBehaviour = make_ChangeBehaviour(inst.components.ghostlybond.ChangeBehaviour)

    -- 假死期间禁止召回
    inst.components.ghostlybond.Recall = make_Recall(inst.components.ghostlybond.Recall)
end


--------------------------------------------------------------------------------------------------------------------------------

local function modify()
    AddPrefabPostInit("wendy", prefab_post_fn)
end
modify()
