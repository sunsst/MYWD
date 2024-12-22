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
        c_announce("安慰阿比")
        if not shadowab:IsCantDefensive() then
            c_announce("成功安慰阿比")
            old_becomeDefensive(inst)
        end
    end
    inst.BecomeDefensive = new_becomeDefensive


    -- 暗影状态带来的增伤
    -- MYWDALERT: 测试服改这里，正式服没有这个函数，测试服有
    -- local old_customdamagemultfn = inst.components.combat.customdamagemultfn
    local new_customdamagemultfn = function()
        if shadowab:IsDamageUP() then
            return TUNING.MYWD.ABIGAIL_SHADOW_DAMAGE_MOD_ADD / inst.components.combat.defaultdamage + 1
        else
            return 1
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
            c_announce("假死状态受伤拦截")
            shadowab:UpdateFeigndeathHealth()
        elseif shadowab:ToFeignDeadOK(val) then
            -- 阿比盖尔尝试进入假死状态
            c_announce("可以进入假死状态")
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

AddPrefabPostInit("abigail", post_fn)


local function brain()

end
