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

function MoonAbigail:_update_planar(status, last_status)
    -- 为了减少出错概率只在启用或停用时调整数值
    local factor
    if last_status == NORMAL and status ~= NORMAL then
        factor = 1
    elseif last_status ~= NORMAL and status == NORMAL then
        factor = -1
    else
        return
    end
    if self.inst.components.planardamage then
        self.inst.components.planardamage:SetBaseDamage(self.inst.components.planardamage:GetBaseDamage() +
            TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DAMAGE * factor)
    end
    if self.inst.components.planardefense then
        self.inst.components.planardefense:SetBaseDefense(self.inst.components.planardefense:GetBaseDefense() +
            TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DEFENSE * factor)
    end
end

function MoonAbigail:_update_effect_wendy_sanity(status, last_status)
    local wendy = self.inst._playerlink
    local sanity = wendy and wendy.components.sanity
    if not sanity then return end

    local factor
    if last_status < ACTIVE and status >= ACTIVE then
        factor = 1
    elseif last_status >= ACTIVE and status < ACTIVE then
        factor = -1
    else
        return
    end
    sanity.dapperness = sanity.dapperness + TUNING.MYWD.WENDY_MOONABIGAIL_EFFECT_SANITY_VALUE * factor
end

function MoonAbigail:_update_aura(status)
    self.inst.components.aura:Enable(status < ACTIVE)
end

-- 清理掉玩家身上的特殊状态
function MoonAbigail:RefreshPlayerState(do_fn, ...)
    self:_update_effect_wendy_sanity(NORMAL, self._status)
    do_fn(...)
    self:_update_effect_wendy_sanity(self._status, NORMAL)
end

-- 更新其他状态
function MoonAbigail:Update(new_state)
    local last_state = self._status
    new_state = new_state or last_state
    self._status = new_state
    self:_update_planar(new_state, last_state)
    self:_update_effect_wendy_sanity(new_state, last_state)
    self:_update_aura(new_state)
end

-- 获得药剂BUFF阶段 √
function MoonAbigail:ToGetBuff()
    if self._status == NORMAL then
        self:Update(GETBUFF)
    end
end

-- 使用技能激活月亮阿比形态阶段 √
function MoonAbigail:ToActive()
    if self._status == GETBUFF then
        self:Update(ACTIVE)
    end
end

-- 回到正常√
function MoonAbigail:ToNormal()
    if self._status ~= NORMAL then
        self:Update(NORMAL)
    end
end

-- 判定温蒂是否能释放月亮阿比技能 √
function MoonAbigail:IsWendyGetSkill()
    local wendy = self.inst._playerlink
    return wendy and wendy.components.skilltreeupdater:IsActivated(ACTIVE_SKILL)
end

-- 判定阿比盖尔是否禁止打架 √
function MoonAbigail:IsCantFight()
    return self._status >= ACTIVE
end

-- 判定阿比盖尔是否禁止范围伤害 √
function MoonAbigail:IsCantAura()
    return self._status >= ACTIVE
end

-- 判定阿比盖尔是否能与植物对话 √
function MoonAbigail:IsTalkToPlants()
    return self._status >= ACTIVE and self.inst.is_defensive
end

-- 判定阿比盖尔是否能发射导弹 √
function MoonAbigail:IsFire()
    return self._status >= ACTIVE and not self.inst.is_defensive
end

-- 判定阿比盖尔是否能抓蝴蝶 √
function MoonAbigail:IsCatchButterfly()
    return self._status >= ACTIVE and self.inst.is_defensive
end

function MoonAbigail:OnSave()
    return {
        status = self._status
    }
end

function MoonAbigail:OnLoad(data)
    self._status = NORMAL
    self:Update(data.status or NORMAL)
end

function MoonAbigail:GetDebugString()
    local state_str = ({ "NORMAL", "GETBUFF", "ACTIVE", "APPEAR", "FEIGNDEATH" })[self._status + 1]
    return state_str
end

return MoonAbigail
