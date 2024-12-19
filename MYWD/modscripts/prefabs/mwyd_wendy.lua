local function testForSanityAuraBuff(inst, oldlist)
    local newlist = {}

    -- IF ACTIVE SISTURN, COLLECT NEARBY PLAYERS
    if TheWorld.components.sisturnregistry and TheWorld.components.sisturnregistry:IsActive() then
        local px, py, pz = inst.Transform:GetWorldPosition()
        newlist = FindPlayersInRange(px, py, pz, 25, true)
    end

    -- SETUP PLAYERS THAT ARE NEW TO THE POLL
    for _, player in ipairs(newlist) do
        local newplayer = true
        for _, previousplayer in ipairs(oldlist) do
            if player == previousplayer then
                newplayer = false
            end
        end

        if newplayer then
            if player.components.sanity then
                local fx = SpawnPrefab("wendy_sanityaura_buff_on_fx")
                player:AddChild(fx)
                player.components.sanity.neg_aura_modifiers:SetModifier(inst, TUNING.WENDYSKILL_SISTURN_SANITY_MODIFYER,
                    "wendyskill" .. inst.GUID)
            end
        end
    end

    -- REMOVE PLAYERS NOW MISSING
    for _, player in ipairs(oldlist) do
        if player.components.sanity then
            local quit = true
            for _, newplayer in ipairs(newlist) do
                if player == newplayer then
                    quit = false
                    break
                end
            end
            if quit then
                local fx = SpawnPrefab("wendy_sanityaura_buff_off_fx")
                player:AddChild(fx)
                player.components.sanity.neg_aura_modifiers:RemoveModifier(inst, "wendyskill" .. inst.GUID)
            end
        end
    end

    return newlist
end

local function checkforshadowsacrifice(inst, data)
    if inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wendy_shadow_3") and
        inst.components.ghostlybond and inst.components.ghostlybond.ghost and not inst.components.ghostlybond.ghost:HasTag("INLIMBO") then
        inst.SoundEmitter:PlaySound("meta5/abigail/abigail_nightmare_buff_stinger")
        inst.components.ghostlybond.ghost:DoShadowBurstBuff(data.stackmult)
    end
end


local function update_sisturn_state(inst, is_active, is_blossom)
    if inst.components.ghostlybond ~= nil then
        if is_blossom and inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wendy_sisturn_3") then
            if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                inst.components.ghostlybond.ghost:AddTag("player_damagescale")
            end
        else
            if inst.components.ghostlybond and inst.components.ghostlybond.ghost then
                inst.components.ghostlybond.ghost:RemoveTag("player_damagescale")
            end
        end
    end
end


local function CustomCombatDamage(inst, target)
    local vex_debuff = target:GetDebuff("abigail_vex_debuff")
    return (vex_debuff ~= nil and vex_debuff.prefab == "abigail_vex_debuff" and TUNING.ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD)
        or
        (vex_debuff ~= nil and vex_debuff.prefab == "abigail_vex_shadow_debuff" and TUNING.ABIGAIL_SHADOW_VEX_GHOSTLYFRIEND_DAMAGE_MOD)
        or (target == inst.components.ghostlybond.ghost and target:HasTag("abigail") and 0)
        or 1
end

local function CustomSPCombatDamage(inst, target)
    return target == inst.components.ghostlybond.ghost and target:HasTag("abigail") and 0
        or 1
end

-------------------------------------------------------------------------------
local SKILL_CHANGE_EVENTS = { "wendy_sisturn" }
local function OnActivateSkill(inst, data)
    if data and data.skill then
        for _, skill_event in pairs(SKILL_CHANGE_EVENTS) do
            if string.sub(data.skill, 1, string.len(skill_event)) == skill_event then
                TheWorld:PushEvent(skill_event .. "skillchanged", inst)
            end
        end
    end
end

local function OnDeactivateSkill(inst, data)
    if data and data.skill then
        for _, skill_event in pairs(SKILL_CHANGE_EVENTS) do
            if string.sub(data.skill, 1, string.len(skill_event)) == skill_event then
                TheWorld:PushEvent(skill_event .. "skillchanged", inst)
            end
        end
    end
end

local function OnSkillTreeInitialized(inst)
    for _, skill_event in pairs(SKILL_CHANGE_EVENTS) do
        TheWorld:PushEvent(skill_event .. "skillchanged", inst)
    end
end

local function OnBabysitterSet(inst, data)
    inst.components.talker:Say(GetString(inst,
        (data and "ANNOUNCE_WENDY_BABYSITTER_SET") or "ANNOUNCE_WENDY_BABYSITTER_STOP"))
end

local function redirect_to_abigail(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if inst.components.ghostlybond ~= nil
        and inst.components.ghostlybond.ghost ~= nil
        and not inst.components.ghostlybond.ghost:IsInLimbo()
        and inst:HasTag("ghostlybond_redirect") then
        inst.components.ghostlybond.ghost.components.health:DoDelta(amount)
        return true
    end
end


local function post_fn(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sanityauraadjuster")
    inst.components.sanityauraadjuster:SetAdjustmentFn(testForSanityAuraBuff)

    inst.components.combat.customdamagemultfn = CustomCombatDamage
    inst.components.combat.customspdamagemultfn =
        CustomSPCombatDamage -- Were using this here but shouldn't really be used.

    -- Skilltree update events
    inst:ListenForEvent("onactivateskill_server", OnActivateSkill)
    inst:ListenForEvent("ondeactivateskill_server", OnDeactivateSkill)
    inst:ListenForEvent("ms_skilltreeinitialized", OnSkillTreeInitialized)

    inst:ListenForEvent("babysitter_set", OnBabysitterSet)

    inst:ListenForEvent("murdered", checkforshadowsacrifice)

    inst:ListenForEvent("onsisturnstatechanged",
        function(world, data)
            print("GOT HERE")
            update_sisturn_state(inst, data.is_active, data.is_blossom)
        end, TheWorld)


    inst.components.health.redirect = redirect_to_abigail
end


AddPrefabPostInit("abigail", post_fn)
