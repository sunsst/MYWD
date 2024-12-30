-- 这是原始的技能书指令表
local origin_command = require "prefabs/ghostcommand_defs"

local all_args = GetAllUpValue(origin_command.GetGhostCommandsFor)


local BASECOMMANDS = all_args["BASECOMMANDS"]
local SKILLTREE_COMMAND_DEFS = all_args["SKILLTREE_COMMAND_DEFS"]
local SOOTHE_ACTION = all_args["SOOTHE_ACTION"]
local RILE_UP_ACTION = all_args["RILE_UP_ACTION"]
local ICON_SCALE = SOOTHE_ACTION.widget_scale
all_args = nil



-------------------------------------------------------------------------------------------------

local function StartAOETargeting(inst)
    if ThePlayer.components.playercontroller then
        ThePlayer.components.playercontroller:StartAOETargetingUsing(inst)
    end
end

local function ReticuleGhostTargetFn(inst)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(7, 0.001, 0))
end


local function GhostSummonSpell(inst, doer, pos)
    inst:RemoveTag("summoning_spell")
    local doer_ghostlybond = doer.components.ghostlybond
    if not doer_ghostlybond or not inst.components.summoningitem then
        return false
    else
        -- MYWDALERT: pos参数正式服是没有的
        doer_ghostlybond:Summon(inst.components.summoningitem.inst, pos)
        return true
    end
end

local UNSUMMON_BASECOMMANDS = { {
    label = STRINGS.GHOSTCOMMANDS.SUMMON,
    onselect = function(inst)
        local spellbook = inst.components.spellbook
        local aoetargeting = inst.components.aoetargeting
        spellbook:SetSpellName(STRINGS.GHOSTCOMMANDS.SUMMON)

        aoetargeting:SetDeployRadius(0)
        aoetargeting:SetRange(TUNING.MYWD.WENDY_SUMMON_ABIGAIL_RADIUS)
        aoetargeting.reticule.reticuleprefab = "reticuleaoeghosttarget"
        aoetargeting.reticule.pingprefab = "reticuleaoeghosttarget_ping"

        aoetargeting.reticule.mousetargetfn = nil
        aoetargeting.reticule.targetfn = ReticuleGhostTargetFn
        aoetargeting.reticule.updatepositionfn = nil
        aoetargeting.reticule.twinstickrange = 15

        inst:AddTag("summoning_spell")
        if TheWorld.ismastersim then
            aoetargeting:SetTargetFX("reticuleaoeghosttarget")
            inst.components.aoespell:SetSpellFn(GhostSummonSpell)
            spellbook:SetSpellFn(nil)
        end
    end,
    execute = StartAOETargeting,
    bank = "spell_icons_wendy",
    build = "spell_icons_wendy",
    anims =
    {
        idle = { anim = "unsummon" },
        focus = { anim = "unsummon_focus", loop = true },
        down = { anim = "unsummon_pressed" },
    },
    widget_scale = ICON_SCALE,
} }


-------------------------------------------------------------------------------------------------

-- 切换至暗影状态
local function GhostChangeShadow(inst, doer)
    if doer then
        local sdab = WD2ABShadow(doer)
        if not sdab then return false end

        if sdab:IsEnteredActive() then return true end

        if doer.components.sanity then
            doer.components.sanity:DoDelta(TUNING.MYWD.WENDY_SHADOW_SKILL_SANITY_UPDATE)
        end
        sdab:ToActive()

        return sdab:IsEnteredActive()
    end
end

local TO_SHADOW = {
    label = STRINGS.GHOSTCOMMANDS.SHADOW,
    onselect = function(inst)
        local spellbook = inst.components.spellbook
        spellbook:SetSpellName(STRINGS.GHOSTCOMMANDS.SHADOW)

        if TheWorld.ismastersim then
            inst.components.aoespell:SetSpellFn(nil)
            spellbook:SetSpellFn(GhostChangeShadow)
        end
    end,
    execute = function(inst)
        if ThePlayer.replica.inventory then
            ThePlayer.replica.inventory:CastSpellBookFromInv(inst)
        end
    end,
    bank = "spell_icons_wendy",
    build = "spell_icons_wendy",
    anims =
    {
        idle = { anim = "rile" },
        focus = { anim = "rile_focus", loop = true },
        down = { anim = "rile_pressed" },
    },
    widget_scale = ICON_SCALE,
}

--------------------------------------------------------------------------------------------------

local function GhostChangeMoon(inst, doer)
    if doer then
        local mnab = WD2ABMoon(doer)
        if not mnab then return false end

        if mnab:IsEnteredActive() then return true end

        if doer.components.sanity then
            doer.components.sanity:DoDelta(TUNING.MYWD.WENDY_MOON_SKILL_SANITY_UPDATE)
        end

        mnab:ToActive()

        return mnab:IsEnteredActive()
    end
end

local TO_MOON = {
    label = STRINGS.GHOSTCOMMANDS.MOON,
    onselect = function(inst)
        local spellbook = inst.components.spellbook
        spellbook:SetSpellName(STRINGS.GHOSTCOMMANDS.MOON)

        if TheWorld.ismastersim then
            inst.components.aoespell:SetSpellFn(nil)
            spellbook:SetSpellFn(GhostChangeMoon)
        end
    end,
    execute = function(inst)
        if ThePlayer.replica.inventory then
            ThePlayer.replica.inventory:CastSpellBookFromInv(inst)
        end
    end,
    bank = "spell_icons_wendy",
    build = "spell_icons_wendy",
    anims =
    {
        idle = { anim = "rile" },
        focus = { anim = "rile_focus", loop = true },
        down = { anim = "rile_pressed" },
    },
    widget_scale = ICON_SCALE,
}

--------------------------------------------------------------------------------------------------


local function GetGhostCommandsFor(owner)
    local commands
    if owner and owner.components.ghostlybond.summoned then
        commands = shallowcopy(BASECOMMANDS)
    else
        commands = shallowcopy(UNSUMMON_BASECOMMANDS)
    end



    -- 切换愤怒与安静状态的图标
    local behaviour_command = (owner:HasTag("has_aggressive_follower") and SOOTHE_ACTION) or RILE_UP_ACTION
    table.insert(commands, behaviour_command)

    -- MYWD: 先强行启用技能书所有技能
    for skill, skill_command in pairs(SKILLTREE_COMMAND_DEFS) do
        if skill_command.label then
            table.insert(commands, skill_command)
        else
            for _, skill_command2 in pairs(skill_command) do
                table.insert(commands, skill_command2)
            end
        end
    end

    return commands
end


--------------------------------------------------------------------------------------------------

local function make_sg_CASTAOE_deststate(old_fn)
    return function(inst, action)
        if action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and action.invobject:HasTag("summoning_spell") then
            return "summon_abigail"
        end
        return old_fn(inst, action)
    end
end

local function SGwilson_post_init(self)
    -- 修改技能书的触发状态到原有的召唤状态
    self.actionhandlers[ACTIONS.CASTAOE].deststate = make_sg_CASTAOE_deststate(self.actionhandlers
        [ACTIONS.CASTAOE].deststate)
end


--------------------------------------------------------------------------------------------------

local function modify()
    -- 添加两个特殊技能点
    -- SKILLTREE_COMMAND_DEFS["mywd_moon_2"] = TO_MOON
    -- SKILLTREE_COMMAND_DEFS["mywd_shadow_2"] = TO_SHADOW
    SKILLTREE_COMMAND_DEFS["mywd_shadow_2"] = { TO_MOON, TO_SHADOW }

    -- 修改技能书的召唤状态到原有的召唤状态
    AddStategraphPostInit("wilson", SGwilson_post_init)


    -- 修改函数
    origin_command.GetGhostCommandsFor = GetGhostCommandsFor
end
modify()
