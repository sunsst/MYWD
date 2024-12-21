local BUFF = {
    UNKNOW = 0,
    SHADOW = 1,
    MOON = 2
    -- NORMAL = 3,
}

local MOON_BUFF_NAME = "ghostlyelixir_mywd_moon_buff"
local SHADOW_BUFF_NAME = "ghostlyelixir_mywd_shadow_buff"
local BUFF_TYPE = "elixir_buff"

local AbigailBuff = Class(function(self, inst)
    self.inst = inst
    self.start_shadow = false
end)

-- 获取绑定的温蒂实体
function AbigailBuff:GetWendy()
    local wendy = self.inst._playerlink
    if wendy and wendy:IsValid() then return wendy end
end

-- 判断自己是否被收回
function AbigailBuff:IsInLimbo()
    return self.inst:IsInLimbo()
end

-- 获取当前的特殊buff
function AbigailBuff:getBuff()
    local bufinst = self.inst.components.debuffable:GetDebuff(BUFF_TYPE)
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
function AbigailBuff:IsShadowBuff()
    return self:getBuff() == BUFF.SHADOW
end

-- 判断当前是否是暗影buff，以及是否达到了二次加强的要求
function AbigailBuff:IsShadowUP()
    return not self:IsInLimbo() and self:IsShadowBuff()
end

-- 更新温蒂范围攻击状态
function AbigailBuff:UpdateWendyAuraState()
    local wendy = self:GetWendy()
    if wendy then
        wendy.components.aura:Enable(self:IsShadowBuff())
    end
end

-- 更新自己的生气状态
function AbigailBuff:UpdateAggressiveState()

end

return AbigailBuff
