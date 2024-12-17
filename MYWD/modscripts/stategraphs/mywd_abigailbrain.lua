local Abigail = require "prefabs/abigail"


local MYWDAbigailBrain = Class(GLOBAL.Brain, function(self, inst)
    GLOBAL.Brain._ctor(self, inst)
end)


local function find_entity(inst, rad, choose_wendy)
    local center_inst = choose_wendy and inst._playerlink or inst
    if not center_inst or not center_inst:IsValid() then
        return
    end

    local x, y, z = center_inst.Transform:GetWorldPosition()

    local min_distance, min_ent
    for _, ent in ipairs(TheSim:FindEntities(x, y, z, rad)) do
        if ent.IsValid and inst.components.combat:CanTarget(ent) then
            local d = center_inst:GetDistanceSqToInst(ent)
            if (min_ent and d < min_distance) or (not min_ent) then
                min_distance = d
                min_ent = ent
            end
        end
    end

    return min_ent
end


local function get_target_positon(inst)
    if not inst or not inst:IsValid() then
        return
    end

    local target = inst.components.combat.target
    if target and target:IsValid() then
        return GLOBAL.BufferedAction(inst, nil, GLOBAL.ACTIONS.WALKTO, nil, target:GetPosition(), nil,
            TUNING.MYWD.ABIGAIL_MOON_IMPACT_DISTANCE - 1)
    end
end


function MYWDAbigailBrain:OnStart()
    local last_time = 0
    local count     = 0

    local tnode     = GLOBAL.ActionNode(function()
        count = count + 1
        local new_time = GLOBAL.GetTime()
        if new_time - last_time > 5 then
            last_time = new_time
            GLOBAL.c_announce(string.format("abbrain\ttime:%d\tcount:%d", last_time, count))
        end
    end)

    --------------------------------------------------------------------------------------------------

    local function find_entity_guard()
        local ent = find_entity(self.inst, TUNING.MYWD.ABIGAIL_MOON_IMPACT_GUARD_RANGE, true)
        self.inst.components.combat:SetTarget(ent)
        return ent
    end

    local function find_entity_hit()
        local target = self.inst.components.combat.target
        if target and target:IsValid() then
            return self.inst:IsNear(target, TUNING.MYWD.ABIGAIL_MOON_IMPACT_DISTANCE)
        end
    end

    local function do_moon_hit()
        self.inst:PushEvent("onmoon_hit")
    end


    local moon_impact_root = GLOBAL.IfNode(find_entity_guard, "Moon Guard Find", GLOBAL.SelectorNode {
        -- 优先尝试原地攻击
        GLOBAL.SequenceNode {
            GLOBAL.ConditionNode(find_entity_hit, "Moon Hit Find"),
            GLOBAL.ActionNode(do_moon_hit),
            GLOBAL.WaitNode(TUNING.MYWD.ABIGAIL_MOON_IMPACT_SLEEP)
        },
        -- 尝试靠近
        -- 没做远离温蒂的判定
        GLOBAL.DoAction(self.inst, get_target_positon, "Move", true, TUNING.MYWD.ABIGAIL_MOON_IMPACT_WALK_TIMEOUT)
    })


    local root = GLOBAL.PriorityNode({
        moon_impact_root,
        tnode
    }, 0.25)

    self.bt = GLOBAL.BT(self.inst, root)
end

AddPrefabPostInit("abigail", function(inst)
    GLOBAL.c_announce("MYWD_BRAIN_OK!")
    inst:SetBrain(MYWDAbigailBrain)
end)
