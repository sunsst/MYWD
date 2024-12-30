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



function ShadowAbigail:_update_planar(status, last_status)
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
            TUNING.MYWD.GHOSTLYELIXIR_MYWD_SHADOW_DAMAGE * factor)
    end
    if self.inst.components.planardefense then
        self.inst.components.planardefense:SetBaseDefense(self.inst.components.planardefense:GetBaseDefense() +
            TUNING.MYWD.GHOSTLYELIXIR_MYWD_SHADOW_DEFENSE * factor)
    end
end

function ShadowAbigail:_update_wendy_aoe(status)
    -- 温蒂的aoe状态在非普通状态都能开启
    local wendy = self.inst._playerlink
    if wendy and wendy.components.aura then
        wendy.components.aura:Enable(status > NORMAL)
    end
end

function ShadowAbigail:_update_regen_state(status)
    -- 阿比盖尔的假死状态停止血量恢复
    local health = self.inst.components.health
    if not health then return end

    if status >= FEIGNDEATH then
        if health.regen ~= nil then
            health:StopRegen()
        end
    else
        if health.regen == nil then
            if health.currenthealth == 0 then
                --正常状态下没有血的阿比会被判断为死亡无法回血
                health:DoDelta(1)
            end
            health:StartRegen(1, 1)
        end
    end
end

function ShadowAbigail:_update_abigail_health(status)
    -- 假死状态保证血量为0
    local health = self.inst.components.health
    if status == FEIGNDEATH and health and health.currenthealth > TUNING.MYWD.ABIGAIL_SHADOW_FEIGNDEAD_HEALTH_CEILING then
        health.currenthealth = TUNING.MYWD.ABIGAIL_SHADOW_FEIGNDEAD_HEALTH_CEILING
        self.inst:RemoveTag("isdead") -- 不填上这个标签阿比盖尔才能挨打
    end
end

function ShadowAbigail:_update_abgail_mood(status)
    if status >= APPEAR and self.inst._playerlink then
        self.inst:BecomeAggressive()
    end
end

-- 刷新玩家身上的特殊状态
function ShadowAbigail:RefreshPlayerState(do_fn, ...)
    self:_update_wendy_aoe(NORMAL)
    self:_update_abgail_mood(NORMAL)
    do_fn(...)
    self:_update_wendy_aoe(self._status)
    self:_update_abgail_mood(self._status)
end

-- 更新其他状态
function ShadowAbigail:Update(new_state)
    local last_state = self._status
    new_state = new_state or last_state
    self._status = new_state
    self:_update_planar(new_state, last_state)
    self:_update_regen_state(new_state)
    self:_update_wendy_aoe(new_state)
    self:_update_abigail_health(new_state)
    self:_update_abgail_mood(new_state)
end

-- 获得药剂BUFF阶段 √
function ShadowAbigail:ToGetBuff()
    if self._status == NORMAL then
        self:Update(GETBUFF)
    end
end

-- 使用技能激活暗影形态阶段 √
function ShadowAbigail:ToActive()
    if self._status == GETBUFF then
        self:Update(ACTIVE)
        self:ToAppear()
    end
end

-- 阿比盖尔生成 √(已出现) √(未出现)
function ShadowAbigail:ToAppear()
    if self._status == ACTIVE and not self.inst:IsInLimbo() then
        self:Update(APPEAR)
    end
end

-- 阿比盖尔假死 √
function ShadowAbigail:ToFeignDeath(currenthealth)
    if not currenthealth then
        currenthealth = self.inst.components.health and self.inst.components.health.currenthealth
    end
    if self._status == APPEAR and currenthealth and currenthealth <= TUNING.MYWD.ABIGAIL_SHADOW_FEIGNDEAD_HEALTH_CEILING then
        self:Update(FEIGNDEATH)
    end
end

-- 回到正常 (药效过期)√ (假死召回)√
function ShadowAbigail:ToNormal()
    if self._status ~= NORMAL then
        self:Update(NORMAL)
    end
end

-- 判定温蒂是否是AOE攻击模式 √
function ShadowAbigail:IsCantAttack()
    return self._status >= GETBUFF
end

-- 判定温蒂是否能释放暗影阿比技能 √
function ShadowAbigail:IsWendyGetSkill()
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

-- 判定阿比是否假死 (不被判断为死亡)√ (不会死亡)√ (假死召回)√
function ShadowAbigail:IsFeignDead()
    return self._status == FEIGNDEATH
end

-- 判定阿比是否重定向伤害到温蒂 √
function ShadowAbigail:IsRedirectDamage()
    return self._status == FEIGNDEATH
end

function ShadowAbigail:OnSave()
    return {
        status = self._status
    }
end

function ShadowAbigail:OnLoad(data)
    self._status = NORMAL
    self:Update(data.status or NORMAL)
end

function ShadowAbigail:GetDebugString()
    local state_str = ({ "NORMAL", "GETBUFF", "ACTIVE", "APPEAR", "FEIGNDEATH" })[self._status + 1]
    return state_str
end

return ShadowAbigail
