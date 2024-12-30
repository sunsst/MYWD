local function make_LinkToPlayer(old_fn)
    return function(inst, player)
        -- 刷新玩家状态
        local sdab = AB2Shadow(inst)
        if sdab then
            sdab:RefreshPlayerState(old_fn, inst, player)
            return
        end

        old_fn(inst, player)
    end
end

local function make_BecomeDefensive(old_fn)
    return function(inst)
        local sdab = AB2Shadow(inst)
        if sdab and sdab:IsCantDefensive() then
            c_announce("拦截安慰阿比") --mywd
            return
        end

        c_announce("成功安慰阿比") --mywd
        old_fn(inst)
    end
end

local function make_customdamagemultfn(old_fn)
    return function(inst, target)
        local v = old_fn(inst, target)

        local sdab = AB2Shadow(inst)
        if sdab and sdab:IsDamageUP() then
            return TUNING.MYWD.ABIGAIL_SHADOW_DAMAGE_MOD_ADD / inst.components.combat.defaultdamage + v
        end

        return v
    end
end

local function new_IsDead(self)
    local sdab = AB2Shadow(self.inst)
    if sdab and sdab:IsFeignDead() then
        return false
    end

    return self.currenthealth <= 0
end

local function make_SetVal(old_fn)
    return function(self, val, cause, afflicter)
        local sdab = AB2Shadow(self.inst)
        if sdab then
            if sdab:IsFeignDead() then
                -- 阿比盖尔已经进入假死状态
                c_announce("假死状态拦截血量调整 " .. val) --mywd
                return
            else
                sdab:ToFeignDeath(val)
                if sdab:IsFeignDead() then
                    c_announce("进入假死状态成功 " .. val) --mywd
                    return
                end
            end
        end
        old_fn(self, val, cause, afflicter)
    end
end

local function new_redirectdamagefn(inst)
    local sdab = AB2Shadow(inst)
    if sdab and sdab:IsRedirectDamage() then
        return AB2WD(inst)
    end
end

local function prefab_post_fn(inst)
    inst:AddComponent("mywd_shadowab")

    -- 优化玩家连接策略
    inst.LinkToPlayer = make_LinkToPlayer(inst.LinkToPlayer)

    -- 禁止阿比盖尔息怒
    inst.BecomeDefensive = make_BecomeDefensive(inst.BecomeDefensive)


    -- 暗影状态带来的增伤
    -- MYWDALERT: 测试服改这里，正式服没有这个函数，测试服有
    inst.components.combat.customdamagemultfn = make_customdamagemultfn(inst.components.combat.customdamagemultfn or
        function() return 1 end)


    -- 重新定义阿比盖尔死亡
    inst.components.health.IsDead = new_IsDead

    -- 修改阿比盖尔的血量调整
    inst.components.health.SetVal = make_SetVal(inst.components.health.SetVal)

    -- 重定向暗影buff期间的伤害到温蒂
    inst.components.combat.redirectdamagefn = new_redirectdamagefn
end

-------------------------------------------------------------------------------------------------------------------------------


local function make_sg_appear_onexit(old_fn)
    return function(inst)
        old_fn(inst)

        local sdab = AB2Shadow(inst)
        if sdab then
            sdab:ToAppear()
        end
    end
end

local function make_sg_walk_start_onenter(old_fn)
    return function(inst)
        local sdab = AB2Shadow(inst)

        if sdab and sdab:IsCantMove() then
            c_announce("拦截慢跑状态") --mywd
            inst.sg:GoToState("idle")
            inst.components.locomotor:Stop()
            return
        end

        old_fn(inst)
    end
end

local function make_sg_run_start_onenter(old_fn)
    return function(inst)
        local sdab = AB2Shadow(inst)

        if sdab and sdab:IsCantMove() then
            c_announce("拦截快跑状态") --mywd
            inst.sg:GoToState("idle")
            inst.components.locomotor:Stop()
            return
        end

        old_fn(inst)
    end
end

local function sg_post_fn(self)
    -- 暗影buff期间当召唤阿比时切换至生成状态
    self.states.appear.onexit = make_sg_appear_onexit(self.states.appear.onexit)

    -- 暗影buff期间当召唤阿比时停止时运动
    self.states.walk_start.onenter = make_sg_walk_start_onenter(self.states.walk_start.onenter)
    self.states.run_start.onenter = make_sg_run_start_onenter(self.states.run_start.onenter)
end

--------------------------------------------------------------------------------------------------------------------------------

local function make_barin_StopNode(self)
    return ConditionNode(function()
        local sdab = AB2Shadow(self.inst)
        return sdab and sdab:IsCantMove()
    end, "ShadowStopMove")
end

local function barin_post_fn(self)
    -- 让阿比盖尔满足条件时不要移动
    table.insert(self.bt.root.children, 1, make_barin_StopNode(self))
end

--------------------------------------------------------------------------------------------------------------------------------

local function modify()
    AddPrefabPostInit("abigail", prefab_post_fn)
    AddStategraphPostInit("abigail", sg_post_fn)
    AddBrainPostInit("abigailbrain", barin_post_fn)
end
modify()
