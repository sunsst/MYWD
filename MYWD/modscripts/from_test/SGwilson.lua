--------------------------------------------------------------------------------------------------------------------
-- MYWD:下面代码复制粘贴自测试服代码不要动，等更新了可以删了

local function post_fn(sg)
    -- 这是魔法书的释放动作
    sg.actionhandlers[ACTIONS.CASTSPELL]      = ActionHandler(ACTIONS.CASTSPELL,
        function(inst, action)
            return action.invobject ~= nil
                and ((action.invobject:HasTag("gnarwail_horn") and "play_gnarwail_horn")
                    or (action.invobject:HasTag("guitar") and "play_strum")
                    or (action.invobject:HasTag("cointosscast") and "cointosscastspell")
                    or (action.invobject:HasTag("crushitemcast") and "crushitemcast")
                    or (action.invobject:HasTag("quickcast") and "quickcastspell")
                    or (action.invobject:HasTag("veryquickcast") and "veryquickcastspell")
                    or (action.invobject:HasTag("mermbuffcast") and "mermbuffcastspell")
                )
                or "castspell"
        end)
    sg.actionhandlers[ACTIONS.CASTAOE]        = ActionHandler(ACTIONS.CASTAOE,
        function(inst, action)
            return action.invobject ~= nil
                and ((action.invobject:HasTag("book") and (inst:HasTag("canrepeatcast") and "book_repeatcast" or "book")) or
                    (action.invobject:HasTag("willow_ember") and (inst:HasTag("canrepeatcast") and "repeatcastspellmind" or "castspellmind")) or
                    (action.invobject:HasTag("remotecontrol") and (inst:HasTag("canrepeatcast") and "remotecast_trigger" or "remotecast_pre")) or
                    (action.invobject:HasTag("abigail_flower") and "commune_with_abigail") or
                    (action.invobject:HasTag("slingshot") and "slingshot_special") or
                    (action.invobject:HasTag("aoeweapon_lunge") and "combat_lunge_start") or
                    (action.invobject:HasTag("aoeweapon_leap") and (action.invobject:HasTag("superjump") and "combat_superjump_start" or "combat_leap_start")) or
                    (action.invobject:HasTag("parryweapon") and "parry_pre") or
                    (action.invobject:HasTag("blowdart") and "blowdart_special") or
                    (action.invobject:HasTag("throw_line") and "throw_line")
                )
                or "castspell"
        end)

    -- 适配新的召唤阿比盖尔的动作
    sg.actionhandlers[ACTIONS.CAST_SPELLBOOK] = ActionHandler(ACTIONS.CAST_SPELLBOOK, function(inst, action)
        return action.invobject ~= nil
            and
            ((action.invobject:HasTag("abigail_flower") and ((action.invobject:HasTag("unsummoning_spell") and "unsummon_abigail") or "commune_with_abigail"))
            )
            or "book"
    end)

    -- 新增·这是新的喝药水动作
    sg.actionhandlers[ACTIONS.APPLYELIXIR]    = ActionHandler(ACTIONS.APPLYELIXIR,
        function(inst, act)
            if act.target and act.target:HasTag("elixir_drinker") then
                if act.invobject.potion_tunings and act.invobject.potion_tunings.super_elixir then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_EXLIIR_TOO_SUPER"))
                    return nil
                end
                return "drinkelixir"
            end
            if inst.components.inventory:FindItem(function(thing) return thing:HasTag("abigail_flower") end) then
                return "applyelixir"
            else
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_NO_ABIGAIL_FLOWER"))
            end
        end)

    -- 新增·这似乎是新的和小鬼魂的交互动作
    -- sg.actionhandlers[ACTIONS.ATTACH_GHOST] = ActionHandler(ACTIONS.ATTACH_GHOST, "dolongaction")

    -- 新增·这是掘墓的动作
    sg.actionhandlers[ACTIONS.GRAVEDIG]       = ActionHandler(ACTIONS.GRAVEDIG,
        function(inst)
            return not inst.sg:HasStateTag("predig")
                and (inst.sg:HasStateTag("digging") and
                    "dig" or
                    "dig_start")
                or nil
        end)



    -- 用药的动作，给阿比盖尔用
    sg.states["applyelixir"] = State {
        name = "applyelixir",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("wendy_elixir")
            inst.SoundEmitter:PlaySound("meta5/wendy/pour_elixir_f17")

            inst.sg.statemem.action = inst:GetBufferedAction()

            if inst.sg.statemem.action ~= nil then
                local invobject = inst.sg.statemem.action.invobject
                local elixir_type = invobject.elixir_buff_type

                inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs",
                    "ghostly_elixirs_" .. elixir_type .. "_swap")

                local flower = inst.components.inventory:FindItem(function(item)
                    return item:HasTag("abigail_flower")
                end)

                if flower ~= nil then
                    local skin_build = flower:GetSkinBuild()
                    if skin_build ~= nil then
                        inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID,
                            flower.AnimState:GetBuild())
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                end
            end

            inst.sg:SetTimeout(26 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(5 * FRAMES, function(inst)
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
                (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    }


    -- 喝药的动作，自己喝
    sg.states["drinkelixir"] = State {
        name = "drinkelixir",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("drink")
            inst.SoundEmitter:PlaySound("meta5/wendy/player_drink")

            inst.sg.statemem.action = inst:GetBufferedAction()

            if inst.sg.statemem.action ~= nil then
                local invobject = inst.sg.statemem.action.invobject
                local elixir_type = invobject.elixir_buff_type

                inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "ghostly_elixirs",
                    "ghostly_elixirs_" .. elixir_type .. "_swap")
            end

            inst.sg:SetTimeout(33 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(31 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
                (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    }
end


AddStategraphPostInit("wilson", post_fn)


local function client_post_fn(sg)
    sg.actionhandlers[ACTIONS.CAST_SPELLBOOK] = ActionHandler(ACTIONS.CAST_SPELLBOOK, function(inst, action)
        return action.invobject ~= nil
            and
            ((action.invobject:HasTag("abigail_flower") and ((action.invobject:HasTag("unsummoning_spell") and "unsummon_abigail") or "commune_with_abigail"))
            )
            or "book"
    end)

    sg.actionhandlers[ACTIONS.APPLYELIXIR] = ActionHandler(ACTIONS.APPLYELIXIR, "pour")

    sg.actionhandlers[ACTIONS.GRAVEDIG] = ActionHandler(ACTIONS.GRAVEDIG,
        function(inst)
            return not (inst.sg:HasStateTag("predig") or inst:HasTag("predig")) and "dig_start" or nil
        end)
end
AddStategraphPostInit("wilson_client", client_post_fn)
