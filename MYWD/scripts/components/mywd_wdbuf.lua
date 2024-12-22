local WendyBuff = Class(function(self, inst)
    self.inst = inst
end)

-- 获取绑定的阿比盖尔实体
function WendyBuff:GetAbigail()
    local ghost = self.inst.components.ghostlybond.ghost
    if ghost and ghost:IsValid() then return ghost end
end

-- 判定温蒂是否能启用AOE攻击模式 √
function WendyBuff:IsWendyAOEShadow()
    local ab = self:GetAbigail()
    return ab and ab.components.mywd_shadowab:IsWendyAOE()
end

-- 判定温蒂是否能释放暗影阿比技能 √
function WendyBuff:IsWendyGetSkillShadow()
    local ab = self:GetAbigail()
    return ab and ab.components.mywd_shadowab:IsWendyGetSkill()
end

-- 判定温蒂是否能得到暗影buff增伤 √
function WendyBuff:IsWendyDamageUPShadow()
    local ab = self:GetAbigail()
    return ab and ab.components.mywd_shadowab:IsWendyDamageUP()
end

-- 判定阿比是否禁止息怒 √
function WendyBuff:IsCantDefensiveShadow()
    local ab = self:GetAbigail()
    return ab and ab.components.mywd_shadowab:IsCantDefensive()
end

-- 激活暗影阿比盖尔 √
function WendyBuff:ToActiveShadow()
    local ab = self:GetAbigail()
    return ab and ab.components.mywd_shadowab:ToActive()
end

-- 判定阿比是否禁止召回 √
function WendyBuff:IsCantInLimboShadow()
    local ab = self:GetAbigail()
    return ab and ab.components.mywd_shadowab:IsCantInLimbo()
end

return WendyBuff
