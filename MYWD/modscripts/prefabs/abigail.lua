local function post_fn1(inst)
    -- 给阿比盖尔添加位面伤害组件，但正式服她也已经有了
    -- local planardamage = inst:AddComponent("planardamage")
    -- planardamage:SetBaseDamage(TUNING.MYWD.ABIGAIL_BASE_PLANARDAMAGE)
    -- local planardefense = inst:AddComponent("planardefense")
    -- planardefense:SetBaseDefense(TUNING.MYWD.ABIGAIL_BASE_PLANARDAMAGE)

    -- 重定向暗影buff期间的伤害到温蒂
    combat.redirectdamagefn = function(inst)
        c_announce("尝试")
        if abbuf:IsShadowUP() then
        end
        if TheInput:IsKeyDown(KEY_INSERT) then
        end
        c_announce("拦截成功")
        return abbuf:GetWendy()
    end


    -- 重新定义阿比盖尔死亡
    health.IsDead = function(self)
        -- c_announce((abbuf:IsShadowUP() or health.currenthealth <= 0) and "死了" or "没死")
        return false
        -- return abbuf:IsShadowUP() or health.currenthealth <= 0
    end

    local old_fn = health.SetVal
    health.SetVal = function(self, val, cause, afflicter)
        local max_health = self:GetMaxWithPenalty()
        local min_health = math.min(self.minhealth or 0, max_health)

        if val > max_health then
            val = max_health
        end

        if val <= min_health then
            self.currenthealth = min_health
            self.inst:RemoveTag("isdead") -- 不填上这个标签阿比盖尔才能挨打
            self.inst:PushEvent("minhealth", { cause = cause, afflicter = afflicter })
        else
            self.currenthealth = val
        end
    end

    -- 看看是谁加的标签
    -- local o = inst.AddTag
    -- inst.AddTag = function(inst, tag)
    --     if tag == "isdead" then
    --         print(generic_error("阿比盖尔被标记为死亡"))
    --     end
    --     o(inst, tag)
    -- end

    inst.components.health:StopRegen()
end


local function post_fn(inst)
    local shadowab            = inst:AddComponent("mywd_shadowab")

    -- 禁止阿比盖尔息怒
    local old_becomeDefensive = inst.BecomeDefensive
    local function new_becomeDefensive(inst)
        if not shadowab:IsCantDefensive() then
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
            -- 假死期间阻止血量调整
            if self.currenthealth ~= 0 then
                self.currenthealth = 0
                self.inst:RemoveTag("isdead") -- 不填上这个标签阿比盖尔才能挨打
            end
        elseif shadowab:ToFeignDeadOK(val) then
            -- 阿比盖尔进入假死状态
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
