local function make_LinkToPlayer(old_fn)
    return function(inst, player)
        -- 刷新玩家状态
        local mnab = AB2Moon(inst)
        if mnab then
            mnab:RefreshPlayerState(old_fn, inst, player)
            return
        end

        old_fn(inst, player)
    end
end


local function post_fn(inst)
    inst:AddComponent("mywd_moonab")

    -- 优化玩家连接策略
    inst.LinkToPlayer = make_LinkToPlayer(inst.LinkToPlayer)

    ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_CATCH_BUTTERFLY_DIST, { 0, 1 })
end

------------------------------------------------------------------------------------------------------------------------

local CatchButterflyNode = require "behaviours/mywd_catchbutterfly"


local function make_barin_fightcondition_fn(old_fn, self)
    return function()
        local mnab = AB2Moon(self.inst)
        if mnab and mnab:IsCantFight() then
            return false
        end
        return old_fn()
    end
end

local function get_follow_pos(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetPosition() or
        inst:GetPosition()
end

local function make_barin_FindFarmPlantNode(self)
    local find_farm_plant_node = FindFarmPlant(self.inst, ACTIONS.INTERACT_WITH, true, get_follow_pos)
    find_farm_plant_node.shouldrun = true

    local talk_node = WhileNode(function()
        local mnab = AB2Moon(self.inst)
        return mnab and mnab:IsTalkToPlants()
    end, "TalkToPlant", find_farm_plant_node)

    return talk_node
end

local function make_barin_CatchButterflyNode(self)
    local catch_butterfly_node = CatchButterflyNode(self.inst, AB2WD,
        TUNING.MYWD.ABIGAIL_MOON_CATCH_BUTTERFLY_DIST, TUNING.MYWD.ABIGAIL_MOON_FIND_BUTTERFLY_RADIUS)

    local catch_node = WhileNode(function()
        local mnab = AB2Moon(self.inst)
        return mnab and mnab:IsCatchButterfly()
    end, "CatchGiveButterfly", catch_butterfly_node)

    return catch_node
end


local function barin_post_fn(self)
    local real_root = self.bt.root.children[#self.bt.root.children].children[2]
    local aggressive_node = real_root.children[#real_root.children]
    local defensive_node = real_root.children[#real_root.children - 1].children[2]


    -- 拦截防御状态打架意图
    local defensive_fightcondition_node = defensive_node.children[2].children[1]
    defensive_fightcondition_node.fn = make_barin_fightcondition_fn(defensive_fightcondition_node.fn, self)

    -- 拦截激怒状态打架意图
    local aggressive_fightcondition_node = aggressive_node.children[2].children[1]
    aggressive_fightcondition_node.fn = make_barin_fightcondition_fn(aggressive_fightcondition_node.fn, self)

    -- 和植物对话
    table.insert(defensive_node.children, 3, make_barin_FindFarmPlantNode(self))

    -- 阿比盖尔能够抓捕蝴蝶
    table.insert(defensive_node.children, #defensive_node.children - 1, make_barin_CatchButterflyNode(self))
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

-- 抓蝴蝶的动作
local catch_butterfly_actionhandle = ActionHandler(ACTIONS.MYWD_CATCH_BUTTERFLY, "catch_butterfly")
local catch_butterfly_state = State {
    name = "catch_butterfly",
    -- tags = { "busy" },

    onenter = function(inst)
        inst:PerformBufferedAction()
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

-- 给蝴蝶的动作
local give_butterfly_actionhandle = ActionHandler(ACTIONS.MYWD_GIVE_BUTTERFLY, "give_butterfly")
local give_butterfly_state = State {
    name = "give_butterfly",
    -- tags = { "busy" },

    onenter = function(inst)
        inst:PerformBufferedAction()
        c_announce("给蝴蝶后的动作") --mywd
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


local function make_sg_appear_onexit(old_fn)
    return function(inst)
        old_fn(inst)
        local mnab = AB2Moon(inst)
        if mnab and mnab:IsCantAura() then
            c_announce("拦截状态机启动范围攻击")
            inst.components.aura:Enable(false)
        end
    end
end



local function sg_post_fn(self)
    -- 照顾作物
    self.actionhandlers[plant_dance_actionhandle.action]     = plant_dance_actionhandle
    self.states[plant_dance_state.name]                      = plant_dance_state

    -- 抓捕蝴蝶
    self.actionhandlers[catch_butterfly_actionhandle.action] = catch_butterfly_actionhandle
    self.states[catch_butterfly_state.name]                  = catch_butterfly_state

    -- 给蝴蝶
    self.actionhandlers[give_butterfly_actionhandle.action]  = give_butterfly_actionhandle
    self.states[give_butterfly_state.name]                   = give_butterfly_state

    -- 拦截状态机启动范围攻击
    self.states.appear.onexit                                = make_sg_appear_onexit(self.states.appear.onexit)
end



local function modify()
    AddPrefabPostInit("abigail", post_fn)
    AddBrainPostInit("abigailbrain", barin_post_fn)
    AddStategraphPostInit("abigail", sg_post_fn)
end
modify()
