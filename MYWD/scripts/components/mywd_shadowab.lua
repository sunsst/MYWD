local NORMAL = 0
local GETBUFF = 1
local ACTIVE = 2
local APPEAR = 3
local FEIGNDEATH = 4

local ACTIVE_SKILL = "mywd_shadow_2"


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
    if wendy then
        wendy.components.aura:Enable(self:IsWendyAOE())
    end
end

function ShadowAbigail:_update_skill()
    local wendy = self.inst._playerlink
    if not wendy then return end
    local items = wendy.components.inventory:FindItems(function(item)
        return item.prefab == "abigail_flower"
    end)
    c_announce("更新技能书") --mywd
    for i, item in ipairs(items) do
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
            if self.inst.components.health.currenthealth == 0 then
                --正常状态下没有血的阿比会被判断为死亡无法回血
                self.inst.components.health:DoDelta(1)
            end
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
        -- self:_update_skill() --依据技能树不需要主动更新了
    end
end

-- 使用技能激活暗影形态阶段 √
function ShadowAbigail:ToActive()
    if self._status == GETBUFF then
        self._status = ACTIVE
        -- self:_update_skill() --依据技能树不需要主动更新了
        self:ToAppear()
    end
end

-- 阿比盖尔生成 √(已出现) √(未出现)
function ShadowAbigail:ToAppear()
    if self._status == ACTIVE and not self.inst:IsInLimbo() then
        self._status = APPEAR

        self.inst:BecomeAggressive()
        c_announce("暗影阿比盖尔生成") --mywd
    end
end

-- 判定阿比是否允许假死，独立出来方便写逻辑
function ShadowAbigail:ToFeignDeadOK(currenthealth)
    return self._status == APPEAR and currenthealth <= 0
end

-- 更新假死状态下的阿比盖尔血量，独立出来方便写逻辑
function ShadowAbigail:UpdateFeigndeathHealth()
    -- 假死期间阻止血量调整
    if self.inst.components.health.currenthealth ~= 0 then
        self.inst.components.health.currenthealth = 0
        self.inst:RemoveTag("isdead") -- 不填上这个标签阿比盖尔才能挨打
    end
end

-- 阿比盖尔假死 √
function ShadowAbigail:ToFeignDeath()
    if self:ToFeignDeadOK(self.inst.components.health.currenthealth) then
        self._status = FEIGNDEATH
        self:_update_regen_state()
    end
end

-- 回到正常 (药效过期)√ (假死召回)√
function ShadowAbigail:ToNormal()
    if self._status > NORMAL then
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
    -- return self._status == GETBUFF --不需要动态更新
    local wendy = self.inst._playerlink
    return wendy and wendy.components.skilltreeupdater:IsActivated(ACTIVE_SKILL)
end

-- 判定温蒂是否能增伤 √
function ShadowAbigail:IsWendyDamageUP()
    return self._status == ACTIVE and self.inst:IsInLimbo()
end

-- 判定阿比是否禁止息怒 (温蒂血亲组件)√ (阿比盖尔自身)√
function ShadowAbigail:IsCantDefensive()
    return self._status >= APPEAR
end

-- 判定阿比是否禁止移动 (行为树)√ (状态机)√
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

-- 判定阿比是否假死 (不被判断为死亡)√ (不会死亡)√ (假死召回)√
function ShadowAbigail:IsFeignDead()
    return self._status == FEIGNDEATH
end

-- 判定阿比是否重定向伤害到温蒂 √
function ShadowAbigail:IsRedirectDamage()
    return self._status == FEIGNDEATH
end

function ShadowAbigail:GetDebugString()
    local state_str = ({ "NORMAL", "GETBUFF", "ACTIVE", "APPEAR", "FEIGNDEATH" })[self._status + 1]
    return state_str
end

return ShadowAbigail
