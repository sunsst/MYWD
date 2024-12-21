require "behaviours/doaction"
require "behaviours/follow"
require "behaviours/wander"

local AbigailBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = { minwaittime = 6, randwaittime = 6 }
local MAX_BABYSIT_WANDER = 6

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local function DanceParty(inst)
    inst:PushEvent("dance")
end

local function HauntAction(inst)
    local haunt_action = BufferedAction(inst, inst._haunt_target, ACTIONS.HAUNT)
    haunt_action:AddSuccessAction(inst._OnHauntTargetRemoved)
    haunt_action:AddFailAction(inst._OnHauntTargetRemoved)
    haunt_action.validfn = function()
        -- InLimbo covers stuff like items getting picked up
        return inst._haunt_target ~= nil and not inst._haunt_target:IsInLimbo()
    end
    return haunt_action
end

local function ShouldDanceParty(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader.sg:HasStateTag("dancing")
end

local function GetTraderFn(inst)
    local leader = inst.components.follower ~= nil and inst.components.follower.leader
    if leader ~= nil then
        return inst.components.trader:IsTryingToTradeWithMe(leader) and leader or nil
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function ShouldWatchMinigame(inst)
    return inst.components.follower.leader ~= nil
        and inst.components.follower.leader.components.minigame_participator ~= nil
        and (inst.components.combat.target == nil or inst.components.combat.target.components.minigame_participator ~= nil)
end

local function WatchingMinigame(inst)
    local leader = inst.components.follower.leader
    return (leader ~= nil
            and leader.components.minigame_participator ~= nil
            and leader.components.minigame_participator:GetMinigame())
        or nil
end

--
local function DefensiveCanFight(inst)
    local target = inst.components.combat.target
    if target ~= nil and not inst.auratest(inst, target) then
        inst.components.combat:GiveUp()
        return false
    end

    if inst:IsWithinDefensiveRange() then
        return true
    elseif inst._playerlink ~= nil and target ~= nil then
        inst.components.combat:GiveUp()
    end

    return false
end

local MAX_AGGRESSIVE_FIGHT_DSQ = math.pow(TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE + 2, 2)
local function AggressiveCanFight(inst)
    local target = inst.components.combat.target
    if target ~= nil and not inst.auratest(inst, target) then
        inst.components.combat:GiveUp()
        return false
    end

    if inst._playerlink then
        if inst:GetDistanceSqToInst(inst._playerlink) < MAX_AGGRESSIVE_FIGHT_DSQ then
            return true
        elseif target ~= nil then
            inst.components.combat:GiveUp()
        end
    end

    return false
end

local function GetBabysitterPos(inst)
    return (inst.ghost_babysitter ~= nil and not inst.sg:HasStateTag("busy") and inst.ghost_babysitter:GetPosition())
        or nil
end

local PRIORITY_NODE_RATE = 0.25
function AbigailBrain:OnStart()
    local watch_game = WhileNode(function() return ShouldWatchMinigame(self.inst) end, "Watching Game",
        PriorityNode({
            Follow(self.inst, WatchingMinigame, TUNING.MINIGAME_CROWD_DIST_MIN, TUNING.MINIGAME_CROWD_DIST_TARGET,
                TUNING.MINIGAME_CROWD_DIST_MAX),
            RunAway(self.inst, "minigame_participator", 5, 7),
            FaceEntity(self.inst, WatchingMinigame, WatchingMinigame),
        }, PRIORITY_NODE_RATE))

    --#1 priority is dancing beside your leader. Obviously.
    local dance = WhileNode(function() return ShouldDanceParty(self.inst) end, "Dance Party",
        PriorityNode({
            Leash(self.inst, GetLeaderPos, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW),
            ActionNode(function() DanceParty(self.inst) end),
        }, PRIORITY_NODE_RATE))

    local transparent_behaviour = WhileNode(function() return self.inst._is_transparent end, "Is Transparent",
        PriorityNode({
            Leash(self.inst, GetLeaderPos, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, true),
            StandStill(self.inst),
        }, PRIORITY_NODE_RATE)
    )

    local haunt_behaviour = WhileNode(function() return self.inst._haunt_target ~= nil end, "Haunt Something",
        DoAction(self.inst, HauntAction, nil, true, TUNING.WENDYSKILL_COMMAND_COOLDOWN)
    )

    --
    local defensive_mode = WhileNode(function() return self.inst.is_defensive end, "DefensiveMove",
        PriorityNode({
            WhileNode(
                function()
                    return self.inst:HasTag("gestalt") and self.inst.components.combat.target and
                        (self.inst.components.combat:InCooldown() or self.inst:HasTag("gestalt_hide"))
                end, "gestalt avoid",
                RunAway(self.inst, function() return self.inst.components.combat.target end, 7, 9)),

            WhileNode(function() return DefensiveCanFight(self.inst) end, "CanFight",
                ChaseAndAttack(self.inst, TUNING.ABIGAIL_DEFENSIVE_MAX_CHASE_TIME)),
            FaceEntity(self.inst, GetTraderFn, KeepTraderFn),

            WhileNode(function() return GetBabysitterPos(self.inst) end, "babysitter",
                Wander(self.inst, GetBabysitterPos, MAX_BABYSIT_WANDER, WANDER_TIMING)
            ),

            Follow(self.inst, function() return self.inst.components.follower.leader end,
                TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW,
                TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW, true),
            Wander(self.inst, nil, nil, WANDER_TIMING),
        }, PRIORITY_NODE_RATE)
    )

    --
    local aggressive_mode = PriorityNode({
        WhileNode(
            function()
                return self.inst:HasTag("gestalt") and self.inst.components.combat.target and
                    (self.inst.components.combat:InCooldown() or self.inst:HasTag("gestalt_hide"))
            end, "gestalt avoid",
            RunAway(self.inst, function() return self.inst.components.combat.target end, 7, 9)),

        WhileNode(function() return AggressiveCanFight(self.inst) end, "CanFight",
            ChaseAndAttack(self.inst, TUNING.ABIGAIL_AGGRESSIVE_MAX_CHASE_TIME)),

        FaceEntity(self.inst, GetTraderFn, KeepTraderFn),

        WhileNode(function() return GetBabysitterPos(self.inst) end, "babysitter",
            Wander(self.inst, GetBabysitterPos, MAX_BABYSIT_WANDER, WANDER_TIMING)
        ),

        Follow(self.inst, function() return self.inst.components.follower.leader end,
            TUNING.ABIGAIL_AGGRESSIVE_MIN_FOLLOW, TUNING.ABIGAIL_AGGRESSIVE_MED_FOLLOW,
            TUNING.ABIGAIL_AGGRESSIVE_MAX_FOLLOW, true),
        Wander(self.inst),
    }, PRIORITY_NODE_RATE)

    --
    local root = PriorityNode({
        ActionNode(function()
            c_announce("抢占")
        end),
        -- ConditionNode(function()
        --     c_announce("判断")
        --     return false
        -- end),
        -- ActionNode(function()
        --     c_announce("抢占失败")
        -- end),
        WhileNode(
            function()
                return not self.inst.sg:HasStateTag("swoop")
            end,
            "<swoop state guard>",
            PriorityNode({

                dance,
                watch_game,
                transparent_behaviour,
                haunt_behaviour,

                defensive_mode,
                aggressive_mode,

            }, PRIORITY_NODE_RATE)
        )
    }, PRIORITY_NODE_RATE)

    self.bt = BT(self.inst, root)
end

return AbigailBrain