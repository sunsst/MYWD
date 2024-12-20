--------------------------------------------------------------------------------------------------------------------
-- MYWD:下面代码复制粘贴自测试服代码不要动，等更新了可以删了


local function MakeAction(id, opt)
    local a = Action(opt)
    a.id = id
    a.str = "DO " .. id
    AddAction(a)
end



-- 给阿比盖尔花花召唤的东西添加优先级防止被技能书动作完全覆盖
ACTIONS.CASTSUMMON.priority = 2
ACTIONS.CASTUNSUMMON.priority = 2


MakeAction("APPLYELIXIR", { mount_valid = true })
MakeAction("GRAVEDIG", { rmb = true, invalid_hold_action = true })
-- MakeAction("ATTACH_GHOST", { mount_valid = true }) -- 这个动作暂不知啥用



ACTIONS.APPLYELIXIR.stroverridefn = function(act)
    if act.invobject then
        if act.target and act.target:HasTag("elixir_drinker") then
            return subfmt(STRINGS.ACTIONS.GIVE.DRINK, { item = act.invobject:GetBasicDisplayName() })
        else
            return subfmt(STRINGS.ACTIONS.GIVE.APPLY, { item = act.invobject:GetBasicDisplayName() })
        end
    end
end

local function find_elixirable_fn(item)
    return item.components.ghostlyelixirable ~= nil
end
ACTIONS.APPLYELIXIR.fn = function(act)
    local doer = act.doer
    local object = act.invobject
    if doer and object and doer.components.inventory then
        if act.target and act.target:HasTag("elixir_drinker") then
            object.components.ghostlyelixir:Apply(doer, act.target)
            return true
        else
            local elixirable_item = doer.components.inventory:FindItem(find_elixirable_fn)
            if elixirable_item then
                return object.components.ghostlyelixir:Apply(doer, elixirable_item)
            else
                return false, "NO_ELIXIRABLE"
            end
        end
    end
end

ACTIONS.GRAVEDIG.fn = function(act)
    local success, reason = false, nil

    local target = act.target
    if target and target.components.gravediggable then
        local tool = act.invobject

        success, reason = target.components.gravediggable:DigUp(tool, act.doer)
        if tool and tool.components.gravedigger then
            tool.components.gravedigger:OnUsed(act.doer)
        end
    end

    return success, reason
end

-- ACTIONS.ATTACH_GHOST.stroverridefn = function(act)
--     if act.doer:HasTag("ghost_is_babysat") then
--         return STRINGS.ACTIONS.ATTACH_GHOST.RETRIEVE
--     else
--         return STRINGS.ACTIONS.ATTACH_GHOST.RELEASE
--     end
-- end

-- ACTIONS.ATTACH_GHOST.fn = function(act)
--     if act.doer.components.ghostlybond and act.doer.components.ghostlybond.ghost then
--         local ghost = act.doer.components.ghostlybond.ghost
--         if ghost.ghost_babysitter then
--             ghost:PushEvent("set_babysitter", nil)
--             act.doer:PushEvent("babysitter_set", nil)
--             return true
--         elseif not act.target.components.container:IsFull() then
--             return false, "SISTURN_OFF"
--         elseif ghost:IsInLimbo() or ghost:GetDistanceSqToInst(act.doer) > 30 * 30 then
--             return false, "ABIGAIL_NOT_NEAR"
--         else
--             ghost:PushEvent("set_babysitter", act.target)
--             act.doer:PushEvent("babysitter_set", act.target)
--             return true
--         end
--     end
-- end
