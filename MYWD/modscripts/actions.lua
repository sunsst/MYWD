local function MYWD_CATCH_BUTTERFLY_FN(act)
    if not act.doer or not act.target or not act.doer:IsValid() or not act.target:IsValid() then
        return false
    end
    if act.target.entity:GetParent() then
        return false
    end

    act.target.entity:SetParent(act.doer.entity)
    c_announce("阿比盖尔抓到蝴蝶") --mywd
    return true
end

local function MYWD_GIVE_BUTTERFLY_FN(act)
    if not act.doer or not act.target or not act.doer:IsValid() or not act.target:IsValid() then
        return false
    end
    if not act.target.components.inventory then
        return false
    end
    if not act.invobject or act.invobject.entity:GetParent() ~= act.doer then
        return false
    end

    act.invobject.entity:SetParent(nil)
    act.target.components.inventory:GiveItem(act.invobject)
    c_announce("阿比盖尔送你蝴蝶") --mywd
    return true
end



local function modify()
    -- 阿比盖尔抓蝴蝶动作
    AddAction("MYWD_CATCH_BUTTERFLY", "Abigail Catch Butterfly", MYWD_CATCH_BUTTERFLY_FN)
    -- 阿比盖尔给蝴蝶动作
    AddAction("MYWD_GIVE_BUTTERFLY", "Abigail Give Butterfly", MYWD_GIVE_BUTTERFLY_FN)

    -- 降低温蒂召唤阿比盖尔动作的优先级，优先使用技能书
    ACTIONS.CASTSUMMON.priority = 0
    ACTIONS.CASTUNSUMMON.priority = 0
end
modify()
