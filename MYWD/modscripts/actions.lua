ACTIONS.MYWD_CATCH_BUTTERFLY = Action()
ACTIONS.MYWD_CATCH_BUTTERFLY.fn = function(act)
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

ACTIONS.MYWD_GIVE_BUTTERFLY = Action()
ACTIONS.MYWD_GIVE_BUTTERFLY.fn = function(act)
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
