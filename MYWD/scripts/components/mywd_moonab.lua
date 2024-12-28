local NORMAL = 0
local GETBUFF = 1
local ACTIVE = 2
-- local APPEAR = 3
-- local FEIGNDEATH = 4


local ACTIVE_SKILL = "mywd_shadow_2"


local MoonAbigail = Class(function(self, inst)
    self.inst = inst
    self._status = NORMAL
end)

function MoonAbigail:_update_planar()
    local factor = self:IsGetPlanarValue() and 1 or -1
    self.inst.components.planardamage:SetBaseDamage(self.inst.components.planardamage:GetBaseDamage() +
        TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DAMAGE * factor)
    self.inst.components.planardefense:SetBaseDefense(self.inst.components.planardefense:GetBaseDefense() +
        TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DEFENSE * factor)
end

function MoonAbigail:_update_effect_wendy_sanity()
    local wendy = self.inst._playerlink
    if wendy then
        -- local factor = self:IsEffectWendySanity() and 1 or -1
        -- wendy.components.sanity.dapperness = wendy.components.sanity.dapperness +
        --     factor * TUNING.MYWD.WENDY_MOONABIGAIL_EFFECT_SANITY_VALUE
        wendy.components.sanity.dapperness = self:IsEffectWendySanity() and
            TUNING.MYWD.WENDY_MOONABIGAIL_EFFECT_SANITY_VALUE or 0
    end
end

function MoonAbigail:_update_aura()
    self.inst.components.aura:Enable(not self:IsCantAura())
end

-- 获得药剂BUFF阶段 √
function MoonAbigail:ToGetBuff()
    if self._status == NORMAL then
        self._status = GETBUFF
        self:_update_planar()
    end
end

-- 使用技能激活月亮阿比形态阶段 √
function MoonAbigail:ToActive()
    if self._status == GETBUFF then
        self._status = ACTIVE
        -- self:_update_skill() --依据技能树不需要主动更新了
        self:_update_effect_wendy_sanity()
        self:_update_aura()
    end
end

-- 回到正常√
function MoonAbigail:ToNormal()
    if self._status > NORMAL then
        self._status = NORMAL
        self:_update_planar()
        self:_update_effect_wendy_sanity()
        self:_update_aura()
    end
end

-- 判定阿比是否获得位面数值 √
function MoonAbigail:IsGetPlanarValue()
    return self._status >= GETBUFF
end

-- 判定温蒂是否能释放月亮阿比技能 √
function MoonAbigail:IsWendyGetSkill()
    -- return self._status == GETBUFF --不需要动态更新
    local wendy = self.inst._playerlink
    return wendy and wendy.components.skilltreeupdater:IsActivated(ACTIVE_SKILL)
end

-- 判定温蒂是否能获得来自月亮阿比的回san √
function MoonAbigail:IsEffectWendySanity()
    return self._status >= ACTIVE
end

-- 判定阿比盖尔是否禁止打架 √
function MoonAbigail:IsCantFight()
    return self._status >= ACTIVE
end

-- 判定阿比盖尔是否禁止范围伤害 √
function MoonAbigail:IsCantAura()
    return self._status >= ACTIVE
end

-- 判定阿比盖尔是否能与植物对话
function MoonAbigail:IsTalkToPlants()
    return self._status >= ACTIVE and self.inst.is_defensive
end

-- 判定阿比盖尔是否能发射导弹
function MoonAbigail:IsFire()
    return self._status >= ACTIVE and not self.inst.is_defensive
end

-- 判定阿比盖尔是否能抓蝴蝶
function MoonAbigail:IsCatchButterfly()
    return self._status >= ACTIVE and self.inst.is_defensive
end

function MoonAbigail:GetDebugString()
    local state_str = ({ "NORMAL", "GETBUFF", "ACTIVE", "APPEAR", "FEIGNDEATH" })[self._status + 1]
    return state_str
end

return MoonAbigail
