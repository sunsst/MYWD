local NORMAL = 0
local GETBUFF = 1
local ACTIVE = 2
local APPEAR = 3
local FEIGNDEATH = 4


local ShadowAbigail = Class(function(self, inst)
    self.inst = inst
    self._status = NORMAL
end)


function ShadowAbigail:_update_planar()
    local factor = self:IsGetPlanarValue() and 1 or -1
    self.inst.components.planardamage:SetBaseDamage(self.inst.components.planardamage:GetBaseDamage() +
        TUNING.MYWD.GHOSTLYELIXIR_MYWD_SHADOW_DAMAGE * factor)
    self.inst.components.planardefense:SetBaseDefense(self.inst.components.planardefense:GetBaseDefense() +
        TUNING.MYWD.GHOSTLYELIXIR_MYWD_SHADOW_DEFENSE * factor)
end

function ShadowAbigail:_update_wendy_aoe()
    local wendy = self.inst._playerlink
    wendy.components.aura:Enable(self:IsWendyAOE())
end

function ShadowAbigail:_update_skill()
    local wendy = self.inst._playerlink
    if not wendy then return end
    local items = wendy.components.inventory:FindItems(function(item)
        return item.prefab == "abigail_flower"
    end)
    for _, item in ipairs(items) do
        item:PushEvent("spellupdateneeded", wendy)
    end
end

function ShadowAbigail:_update_regen_state()
    if self:IsStopRegen() then
        if self.inst.components.health.regen ~= nil then
            self.inst.components.health:StopRegen()
        end
    else
        if self.inst.components.health.regen == nil then
            self.inst.components.health:StartRegen(1, 1)
        end
    end
end

-- 获得药剂BUFF阶段 √
function ShadowAbigail:ToGetBuff()
    if self._status == NORMAL then
        self._status = GETBUFF
        self:_update_planar()
        self:_update_wendy_aoe()
        self:_update_skill()
    end
end

-- 使用技能激活暗影形态阶段 √
function ShadowAbigail:ToActive()
    if self._status == GETBUFF then
        self._status = ACTIVE
        self:_update_skill()
        self:ToAppear()
    end
end

-- 阿比盖尔生成 √(已出现) √(未出现)
function ShadowAbigail:ToAppear()
    if self._status == ACTIVE and not self.inst:IsInLimbo() then
        self._status = APPEAR
        self.inst:BecomeAggressive()
    end
end

-- 判定阿比是否允许假死，独立出来方便写逻辑
function ShadowAbigail:ToFeignDeadOK(currenthealth)
    return self._status == APPEAR and currenthealth <= 0
end

-- 阿比盖尔假死 √
function ShadowAbigail:ToFeignDeath()
    if self:ToFeignDeadOK(self.inst.components.health.currenthealth) then
        self._status = FEIGNDEATH
        self:_update_regen_state()
    end
end

-- 判定阿比是否允许回到正常，独立出来方便写逻辑
function ShadowAbigail:ToNormalOK()
    return self._status > NORMAL
end

-- 回到正常 (药效过期)√ (死亡召回)√
function ShadowAbigail:ToNormal()
    if self:ToNormalOK() then
        local refresh_health = self._status == FEIGNDEATH
        self._status = NORMAL
        if refresh_health then self.inst.components.health.currenthealth = 0 end
        self:_update_wendy_aoe()
        self:_update_planar()
        self:_update_regen_state()
    end
end

-- 判定温蒂是否是AOE攻击模式 √
function ShadowAbigail:IsWendyAOE()
    return self._status >= GETBUFF
end

-- 判定阿比是否获得位面数值 √
function ShadowAbigail:IsGetPlanarValue()
    return self._status >= GETBUFF
end

-- 判定温蒂是否能释放暗影阿比技能 √
function ShadowAbigail:IsWendyGetSkill()
    return self._status == GETBUFF
end

-- 判定温蒂是否能增伤 √
function ShadowAbigail:IsWendyDamageUP()
    return self._status == ACTIVE
end

-- 判定阿比是否禁止息怒 (温蒂血亲组件)√ (阿比盖尔自身)√
function ShadowAbigail:IsCantDefensive()
    return self._status >= APPEAR
end

-- 判定阿比是否禁止移动 √
function ShadowAbigail:IsCantMove()
    return self._status >= APPEAR
end

-- 判定阿比是否增伤 √
function ShadowAbigail:IsDamageUP()
    return self._status >= APPEAR
end

-- 判定阿比是否禁止召回 (温蒂血亲组件)√ (阿比盖尔状态机，如果没问题别改)×
function ShadowAbigail:IsCantInLimbo()
    return self._status == APPEAR
end

-- 判定阿比是否禁止自然回血 √
function ShadowAbigail:IsStopRegen()
    return self._status == FEIGNDEATH
end

-- 判定阿比是否假死 (不被判断为死亡)√ (不会死亡)√
function ShadowAbigail:IsFeignDead()
    return self._status == FEIGNDEATH
end

-- 判定阿比是否重定向伤害到温蒂 √
function ShadowAbigail:IsCanRedirectDamage()
    return self._status == FEIGNDEATH
end
