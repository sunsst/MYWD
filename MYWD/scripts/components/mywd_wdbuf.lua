local BUFF = {
    UNKNOW = 0,
    SHADOW = 1,
    MOON = 2
    -- NORMAL = 3,
}

local MOON_BUFF_NAME = "ghostlyelixir_mywd_moon_buff"
local SHADOW_BUFF_NAME = "ghostlyelixir_mywd_shadow_buff"
local BUFF_TYPE = "elixir_buff"

local WendyBuff = Class(function(self, inst)
    self.inst = inst
end)

-- 获取绑定的阿比盖尔实体
function WendyBuff:GetAbigail()
    local ghost = self.inst.components.ghostlybond.ghost
    if ghost and ghost:IsValid() then return ghost end
end

-- 判断温蒂是否收回
function WendyBuff:IsLimbolAbigail()
    local ab = self:GetAbigail()
    return ab and ab:IsInLimbo()
end

-- 获取当前的特殊buff
function WendyBuff:getBuff()
    local ab = self:GetAbigail()
    if not ab then return BUFF.UNKNOW end

    local bufinst = ab.components.debuffable:GetDebuff(BUFF_TYPE)
    if not bufinst then
        return BUFF.UNKNOW
    elseif bufinst.prefab == SHADOW_BUFF_NAME then
        return BUFF.SHADOW
    elseif bufinst.prefab == MOON_BUFF_NAME then
        return BUFF.MOON
    end

    return BUFF.UNKNOW
end

-- 判断当前是否是暗影buff
function WendyBuff:IsShadowBuff()
    return self:getBuff() == BUFF.SHADOW
end

-- 判断当前是否是暗影buff，以及是否达到了二次增强的要求
function WendyBuff:IsShadowUP()
    return self:IsLimbolAbigail() and self:IsShadowBuff()
end

return WendyBuff
