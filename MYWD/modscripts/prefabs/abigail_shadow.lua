local function post_fn(inst)
    local shadowab = inst:AddComponent("mywd_shadowab")

    -- 连接玩家优化
    local old_linktoplayer = inst.LinkToPlayer
    local function new_linktoplayer(inst, player)
        old_linktoplayer(inst, player)
        -- 重新开启玩家的范围伤害
        if shadowab:IsWendyAOE() then
            player.components.aura:Enable(true)
        end
    end
    inst.LinkToPlayer = new_linktoplayer

    -- 禁止阿比盖尔息怒
    local old_becomeDefensive = inst.BecomeDefensive
    local function new_becomeDefensive(inst)
        if shadowab:IsCantDefensive() then
            c_announce("拦截安慰阿比") --mywd
            return
        end
        c_announce("成功安慰阿比") --mywd
        old_becomeDefensive(inst)
    end
    inst.BecomeDefensive = new_becomeDefensive


    -- 暗影状态带来的增伤
    -- MYWDALERT: 测试服改这里，正式服没有这个函数，测试服有
    local old_customdamagemultfn = inst.components.combat.customdamagemultfn or function() return 1 end
    local new_customdamagemultfn = function(inst, target)
        local v = old_customdamagemultfn(inst, target)
        if shadowab:IsDamageUP() then
            return TUNING.MYWD.ABIGAIL_SHADOW_DAMAGE_MOD_ADD / inst.components.combat.defaultdamage + v
        else
            return v
        end
    end
    inst.components.combat.customdamagemultfn = new_customdamagemultfn


    -- 重新定义阿比盖尔死亡
    local function new_isdeadfn(self)
        if shadowab:IsFeignDead() then
            return false
        else
            return self.currenthealth <= 0
        end
    end
    inst.components.health.IsDead = new_isdeadfn

    -- 修改阿比盖尔的血量调整
    local old_setvalfn = inst.components.health.SetVal
    local function new_setvalfn(self, val, cause, afflicter)
        if shadowab:IsFeignDead() then
            -- 阿比盖尔已经进入假死状态
            c_announce("拦截血量调整,假死状态 " .. val) --mywd
            shadowab:UpdateFeigndeathHealth()
        elseif shadowab:ToFeignDeadOK(val) then
            -- 阿比盖尔尝试进入假死状态
            c_announce("拦截血量调整，尝试进入假死 " .. val) --mywd
            shadowab:UpdateFeigndeathHealth()
            shadowab:ToFeignDeath()
        else
            old_setvalfn(self, val, cause, afflicter)
        end
    end
    inst.components.health.SetVal = new_setvalfn



    -- 重定向暗影buff期间的伤害到温蒂
    local function new_redirectdamagefn(inst)
        if inst._playerlink and shadowab:IsCanRedirectDamage() then
            return inst._playerlink
        end
    end
    inst.components.combat.redirectdamagefn = new_redirectdamagefn
end

local function sg_post_fn(self)
    -- 暗影buff期间当召唤阿比时切换至生成状态
    local old_appear_onexit = self.states.appear.onexit
    self.states.appear.onexit = function(inst)
        old_appear_onexit(inst)
        inst.components.mywd_shadowab:ToAppear()
    end


    -- 暗影buff期间当召唤阿比时停止时运动
    local old_walk_start_onenter = self.states.walk_start.onenter
    self.states.walk_start.onenter = function(inst)
        if inst.components.mywd_shadowab:IsCantMove() then
            c_announce("拦截快跑状态") --mywd
            inst.sg:GoToState("idle")
            inst.components.locomotor:Stop()
        else
            old_walk_start_onenter(inst)
        end
    end
    local old_run_start_onenter = self.states.run_start.onenter
    self.states.run_start.onenter = function(inst)
        if inst.components.mywd_shadowab:IsCantMove() then
            c_announce("拦截慢跑状态") --mywd
            inst.sg:GoToState("idle")
            inst.components.locomotor:Stop()
        else
            old_run_start_onenter(inst)
        end
    end
end


local function barin_post_fn(self)
    -- 让阿比盖尔满足条件时不要移动
    local shadow_abigail_node = ConditionNode(function() return self.inst.components.mywd_shadowab:IsCantMove() end,
        "Shdaow Abigail")
    table.insert(self.bt.root.children, 1, shadow_abigail_node)
end


local function modify()
    AddPrefabPostInit("abigail", post_fn)
    AddStategraphPostInit("abigail", sg_post_fn)
    AddBrainPostInit("abigailbrain", barin_post_fn)
end
modify()
