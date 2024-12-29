-- 这是原始的技能书指令表
local origin_command = require "prefabs/ghostcommand_defs"

local all_args = GetAllUpValue(origin_command.GetGhostCommandsFor)

local BASECOMMANDS = all_args["BASECOMMANDS"]
local SKILLTREE_COMMAND_DEFS = all_args["SKILLTREE_COMMAND_DEFS"]
local SOOTHE_ACTION = all_args["SOOTHE_ACTION"]
local RILE_UP_ACTION = all_args["RILE_UP_ACTION"]
local ICON_SCALE = SOOTHE_ACTION.widget_scale


all_args = nil

-- 切换至暗影状态
local function GhostChangeShadow(inst, doer)
    if doer then
        doer.components.sanity:DoDelta(TUNING.MYWD.WENDY_SHADOW_SKILL_SANITY_UPDATE)
        doer.components.mywd_wdbuf:ToActiveShadow()
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
        doer.components.sanity:DoDelta(TUNING.MYWD.WENDY_MOON_SKILL_SANITY_UPDATE)
        doer.components.mywd_wdbuf:ToActiveMoon()
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
    local commands = shallowcopy(BASECOMMANDS)


    -- 切换愤怒与安静状态的图标
    local behaviour_command = (owner:HasTag("has_aggressive_follower") and SOOTHE_ACTION) or RILE_UP_ACTION
    table.insert(commands, behaviour_command)

    -- MYWD: 添加两个我们自己的技能
    if owner and owner.components.mywd_wdbuf then
        if owner.components.mywd_wdbuf:IsWendyGetSkillShadow() then
            table.insert(commands, TO_SHADOW)
        end
        if owner.components.mywd_wdbuf:IsWendyGetSkillMoon() then
            table.insert(commands, TO_MOON)
        end
    end

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

origin_command.GetGhostCommandsFor = GetGhostCommandsFor
