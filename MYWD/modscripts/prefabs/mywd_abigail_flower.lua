local function CLIENT_ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()

    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
            break
        end
    end
    return pos
end

local GetGhostCommandsFor = GHOSTCOMMAND_DEFS.GetGhostCommandsFor

local function updatespells(inst, owner)
    c_announce("")

    if owner then
        if owner.HUD then owner.HUD:CloseSpellWheel() end
        inst.components.spellbook:SetItems(GetGhostCommandsFor(owner))
    else
        inst.components.spellbook:SetItems(nil)
    end
end

local function DoClientUpdateSpells(inst, force)
    local owner = (inst.replica.inventoryitem:IsHeld() and ThePlayer) or nil
    if owner ~= inst._owner then
        if owner then
            updatespells(inst, owner)
        end

        if inst._owner then
            inst:RemoveEventCallback("onactivateskill_client", inst._onskillrefresh_client, inst._owner)
            inst:RemoveEventCallback("ondeactivateskill_client", inst._onskillrefresh_client, inst._owner)
        end
        inst._owner = owner
        if owner then
            inst:ListenForEvent("onactivateskill_client", inst._onskillrefresh_client, owner)
            inst:ListenForEvent("ondeactivateskill_client", inst._onskillrefresh_client, owner)
        end
    elseif force and owner then
        updatespells(inst, owner)
    end
end

local function OnUpdateSpellsDirty(inst)
    inst:DoTaskInTime(0, DoClientUpdateSpells, true)
end
-- CLIENT-SIDE
--local SPELLBOOK_SOUND_LOOP = "wendy_flower_open"
local function CLIENT_OnOpenSpellBook(_)
    --TheFocalPoint.SoundEmitter:PlaySound("meta3/willow/ember_container_open", SPELLBOOK_SOUND_LOOP)
end

local function CLIENT_OnCloseSpellBook(_)
    --TheFocalPoint.SoundEmitter:KillSound(SPELLBOOK_SOUND_LOOP)
end

local function topocket(inst, owner)
    if owner ~= inst._owner then
        inst._updatespells:push()
        updatespells(inst, owner)
        if inst._owner then
            inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh_server, inst._owner)
            inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh_server, inst._owner)
        end
        inst._owner = owner
        if owner then
            inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh_server, owner)
            inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh_server, owner)
        end
    end

    inst:ListenForEvent("ghostlybond_summoncomplete", inst._onsummonstatechanged_server, owner)
    inst:ListenForEvent("ghostlybond_recallcomplete", inst._onsummonstatechanged_server, owner)
end

local function toground(inst)
    -- Update our spell set to nothing
    if inst._owner then
        inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh_server, inst._owner)
        inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh_server, inst._owner)
        inst:RemoveEventCallback("ghostlybond_summoncomplete", inst._onsummonstatechanged_server, inst._owner)
        inst:RemoveEventCallback("ghostlybond_recallcomplete", inst._onsummonstatechanged_server, inst._owner)
        inst._owner = nil

        inst._updatespells:push()
        updatespells(inst, nil)
    end
end

local SPELLBOOK_RADIUS = 100
local function post_fn(inst)
    local spellbook = inst:AddComponent("spellbook")
    spellbook:SetRequiredTag("ghostlyfriend")
    spellbook:SetRadius(SPELLBOOK_RADIUS)
    spellbook:SetFocusRadius(SPELLBOOK_RADIUS)
    spellbook:SetItems(GHOSTCOMMAND_DEFS.GetBaseCommands())
    spellbook:SetOnOpenFn(CLIENT_OnOpenSpellBook)
    spellbook:SetOnCloseFn(CLIENT_OnCloseSpellBook)
    spellbook.closesound = "meta3/willow/ember_container_close"

    local aoetargeting = inst:AddComponent("aoetargeting")
    aoetargeting:SetAllowWater(true)
    aoetargeting.reticule.targetfn = CLIENT_ReticuleTargetAllowWaterFn
    aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    aoetargeting.reticule.ease = true
    aoetargeting.reticule.mouseenabled = true
    aoetargeting.reticule.twinstickmode = 1
    aoetargeting.reticule.twinstickrange = 15

    inst._updatespells = net_event(inst.GUID, "abigail_flower._updatespells")

    if not TheWorld.ismastersim then
        inst._onskillrefresh_client = function(_) DoClientUpdateSpells(inst, true) end

        inst:ListenForEvent("abigail_flower._updatespells", OnUpdateSpellsDirty)
        OnUpdateSpellsDirty(inst)

        return inst
    end



    inst._onskillrefresh_server = function(owner)
        updatespells(inst, owner)
    end
    inst._onsummonstatechanged_server = function(owner)
        inst._updatespells:push()
        updatespells(inst, owner)
    end
    inst:AddComponent("aoespell")

    -- inst:AddComponent("inventoryitem")
    -- inst:AddComponent("lootdropper")


    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    inst:ListenForEvent("spellupdateneeded", updatespells)
end


-- AddPrefabPostInit("abigail_flower", post_fn)
