require "behaviours/findfarmplant"


local function post_fn(inst)
    local moonab = inst:AddComponent("mywd_moonab")

    -- 切换激怒状态时更新阿比的月亮状态
    -- 要用用特殊攻击，用不到这个，平时也没必要禁止
    -- local old_become_defensive_fn = inst.BecomeDefensive
    -- local new_become_defensive_fn = function(inst)
    --     old_become_defensive_fn(inst)
    --     if inst.is_defensive then
    --         -- 是否启用范围攻击
    --         inst.components.aura:Enable(moonab:IsCantAura())
    --     end
    -- end
    -- inst.BecomeDefensive = new_become_defensive_fn
    -- local old_become_aggressive_fn = inst.BecomeAggressive
    -- local new_become_aggressive_fn = function(inst)
    --     old_become_aggressive_fn(inst)
    --     if not inst.is_defensive then
    --         -- 是否启用范围攻击
    --         inst.components.aura:Enable(moonab:IsCantAura())
    --     end
    -- end
    -- inst.BecomeAggressive = new_become_aggressive_fn


    ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_CATCH_BUTTERFLY_DIST, { 0, 1 })
    ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_FIND_BUTTERFLY_RADIUS, { 0, 0.2 })
end

------------------------------------------------------------------------------------------------------------------------
local CATCH_BUTTERFLY_TIMEOUT = 0.1

local function GetFollowPos(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetPosition() or
        inst:GetPosition()
end



local function barin_post_fn(self)
    local real_root = self.bt.root.children[#self.bt.root.children].children[2]
    local aggressive_node = real_root.children[#real_root.children]
    local defensive_node = real_root.children[#real_root.children - 1].children[2]


    -- 拦截防御状态打架意图
    local defensive_fight_condition_node = defensive_node.children[2].children[1]
    local old_defensive_fight_condition_fn = defensive_fight_condition_node.fn
    local function new_defensive_fight_condition_fn()
        if self.inst.components.mywd_moonab:IsCantFight() then
            return false
        else
            return old_defensive_fight_condition_fn()
        end
    end
    defensive_fight_condition_node.fn = new_defensive_fight_condition_fn

    -- 拦截激怒状态打架意图
    local aggressive_fight_condition_node = aggressive_node.children[2].children[1]
    local old_aggressive_fight_condition_fn = aggressive_fight_condition_node.fn
    local function new_aggressive_fight_condition_fn()
        if self.inst.components.mywd_moonab:IsCantFight() then
            return false
        else
            return old_aggressive_fight_condition_fn()
        end
    end
    aggressive_fight_condition_node.fn = new_aggressive_fight_condition_fn

    -- 和植物对话
    local find_farm_plant_node = FindFarmPlant(self.inst, ACTIONS.INTERACT_WITH, true, GetFollowPos)
    find_farm_plant_node.shouldrun = true
    local talk_node = WhileNode(function()
        return self.inst.components.mywd_moonab:IsTalkToPlants()
    end, "TalkToPlants", find_farm_plant_node)
    table.insert(defensive_node.children, 3, talk_node)

    ---------------------------------------------------------------------------------------------------------------------------------
    ---MYWDALERT:记得来优化一下
    -- 抓蝴蝶
    local finded_butterfly = nil
    local catched_butterfly = nil

    local function find_butterfly()
        if catched_butterfly then
            return false
        end
        if not finded_butterfly then
            print("找到蝴蝶") --mywd
            finded_butterfly = FindEntity(self.inst, TUNING.MYWD.ABIGAIL_MOON_FIND_BUTTERFLY_RADIUS, nil, { "butterfly" },
                { "INLIMBO" })
        end
        return finded_butterfly
    end
    local function move_to_butterfly()
        if finded_butterfly then
            return BufferedAction(self.inst, finded_butterfly, ACTIONS.WALKTO, nil, nil, nil,
                TUNING.MYWD.ABIGAIL_MOON_CATCH_BUTTERFLY_DIST)
        end
    end
    local function give_butterfly()
        if catched_butterfly then
            return BufferedAction(self.inst, self.inst._playerlink, ACTIONS.WALKTO, nil, nil, nil,
                TUNING.MYWD.ABIGAIL_MOON_CATCH_BUTTERFLY_DIST)
        end
    end

    local give_butterfly_node = IfNode(function()
        return catched_butterfly
    end, "FindCatchedButterfly", SequenceNode({
        DoAction(self.inst, give_butterfly, "GiveButterfly", true, CATCH_BUTTERFLY_TIMEOUT),
        ActionNode(function()
            self.inst._playerlink.components.inventory:GiveItem(catched_butterfly)
            catched_butterfly = nil
            c_announce("阿比盖尔送你蝴蝶") --mywd
        end)
    }))

    local catch_butterfly_node = IfNode(find_butterfly, "FindButterfly", SequenceNode({
        DoAction(self.inst, move_to_butterfly, "CatchButterfly", true, CATCH_BUTTERFLY_TIMEOUT),
        ActionNode(function()
            catched_butterfly = finded_butterfly
            finded_butterfly = nil
            if catched_butterfly then
                catched_butterfly.entity:SetParent(self.inst.entity)
            end
            c_announce("找到蝴蝶") --mywd
            self.inst.sg:GoToState("catch_butterfly_dance")
        end)
    }))

    local catch_butterfly_base_node = WhileNode(function()
        return self.inst.components.mywd_moonab:IsCatchButterfly()
    end, "MoonAbCatchButterfly", PriorityNode({
        give_butterfly_node,
        catch_butterfly_node
    }, 0.1))
    table.insert(defensive_node.children, #defensive_node.children - 1, catch_butterfly_base_node)
end

-------------------------------------------------------------------------------------------------------------------------------


-- 与植物对话
local plant_dance_actionhandle = ActionHandler(ACTIONS.INTERACT_WITH, "plant_dance")
local plant_dance_state = State {
    name = "plant_dance",
    tags = { "busy" },

    onenter = function(inst)
        c_announce("与植物对话") --mywd
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("dance")
    end,

    events =
    {
        EventHandler("animover", function(inst)
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end)
    },
}

local catch_butterfly_state = State {
    name = "catch_butterfly_dance",
    tags = { "busy" },

    onenter = function(inst)
        c_announce("捕捉后的动作") --mywd
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("dance")
    end,

    events =
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end)
    },
}

local function sg_post_fn(self)
    self.actionhandlers[plant_dance_actionhandle.action] = plant_dance_actionhandle
    self.states[plant_dance_state.name] = plant_dance_state
    self.states[catch_butterfly_state.name] = catch_butterfly_state

    local old_appear_onexit = self.states["appear"].onexit
    local function new_appear_onexit(inst)
        old_appear_onexit(inst)
        if inst.components.mywd_moonab:IsCantAura() then
            c_announce("拦截状态机启动范围攻击")
            inst.components.aura:Enable(false)
        end
    end
    self.states["appear"].onexit = new_appear_onexit
end



local function modify()
    AddPrefabPostInit("abigail", post_fn)
    AddBrainPostInit("abigailbrain", barin_post_fn)
    AddStategraphPostInit("abigail", sg_post_fn)
end
modify()
