local function onpercent(self)
    if self.inst.components.combat ~= nil then
        self.inst.components.combat.panic_thresh = self.inst.components.combat.panic_thresh
    end
end

local function oncurrenthealth(self, currenthealth)
    c_announce("拦截死亡")
    self.inst.replica.health:SetCurrent(currenthealth)
    if not self.inst.components.mywd_abbuf:IsShadowUP() then
        -- self.inst.replica.health:SetIsDead(currenthealth <= 0)
    end
    local repairable = self.inst.components.repairable
    if repairable then
        repairable:SetHealthRepairable(currenthealth < self.maxhealth)
    end
    onpercent(self)
end

local function post_fn(inst)
    local abbuf = inst:AddComponent("mywd_abbuf")
    local combat = inst.components.combat
    local health = inst.components.health

    -- 暗影增伤
    -- MYWDALERT: 测试服改这里，正式服没有这个函数，测试服有
    -- local old_customdamagemultfn = inst.components.combat.customdamagemultfn
    combat.customdamagemultfn = function(inst, target)
        return abbuf:IsShadowUP() and
            TUNING.MYWD.ABIGAIL_SHADOW_DAMAGE_MOD_ADD / combat.defaultdamage + 1 or 1
    end



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

AddPrefabPostInit("abigail", post_fn)
