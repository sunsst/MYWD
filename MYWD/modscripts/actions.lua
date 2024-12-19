-- 给阿比盖尔花花召唤的东西添加优先级防止被技能书动作完全覆盖
ACTIONS.CASTSUMMON.priority = 2
ACTIONS.CASTUNSUMMON.priority = 2




local function MakeAction(id, opt)
    local a = Action(opt)
    a.id = id
    a.str = "DO " .. id
    AddAction(a)
end




--------------------------------------------------------------------------------------------------------------------
-- MYWD:下面代码复制粘贴自测试服代码不要动，等更新了可以删了

local function DefaultRangeCheck(doer, target)
    if target == nil then
        return
    end
    local target_x, target_y, target_z = target.Transform:GetWorldPosition()
    local doer_x, doer_y, doer_z = doer.Transform:GetWorldPosition()
    local dst = distsq(target_x, target_z, doer_x, doer_z)
    return dst <= 16
end
MakeAction("APPLYELIXIR", { mount_valid = true })
MakeAction("NABBAG", { rmb = true, distance = 1.8, rangecheckfn = DefaultRangeCheck, invalid_hold_action = true })
MakeAction("ATTACH_GHOST", { mount_valid = true })
MakeAction("GRAVEDIG", { rmb = true, invalid_hold_action = true })
MakeAction("MUTATE", { priority = 2, invalid_hold_action = true, mount_valid = true })
MakeAction("CUSTOMIZE_WOBY_BADGES", { distance = 1.5, invalid_hold_action = true })
MakeAction("WOBY_PICKUP", { arrivedist = 2 })
MakeAction("CONTAINER_INSTALL_ITEM", { priority = 3, rmb = true, instant = true, mount_valid = true })

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

ACTIONS.ATTACH_GHOST.stroverridefn = function(act)
    if act.doer:HasTag("ghost_is_babysat") then
        return STRINGS.ACTIONS.ATTACH_GHOST.RETRIEVE
    else
        return STRINGS.ACTIONS.ATTACH_GHOST.RELEASE
    end
end

ACTIONS.ATTACH_GHOST.fn = function(act)
    if act.doer.components.ghostlybond and act.doer.components.ghostlybond.ghost then
        local ghost = act.doer.components.ghostlybond.ghost
        if ghost.ghost_babysitter then
            ghost:PushEvent("set_babysitter", nil)
            act.doer:PushEvent("babysitter_set", nil)
            return true
        elseif not act.target.components.container:IsFull() then
            return false, "SISTURN_OFF"
        elseif ghost:IsInLimbo() or ghost:GetDistanceSqToInst(act.doer) > 30 * 30 then
            return false, "ABIGAIL_NOT_NEAR"
        else
            ghost:PushEvent("set_babysitter", act.target)
            act.doer:PushEvent("babysitter_set", act.target)
            return true
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

ACTIONS.MUTATE.stroverridefn = function(act)
    return act.target and act.target.getghostgestalttarget
        and subfmt(STRINGS.ACTIONS.MUTATE.MUTATE_TARGET, { target = act.target:getghostgestalttarget(act.doer) })
        or nil
end

ACTIONS.MUTATE.fn = function(act)
    local success, reason = false, nil

    local target = act.target
    if target and target.components.ghostgestalter then
        success, reason = target.components.ghostgestalter:DoMutate(act.doer)
    end

    return success, reason
end

ACTIONS.CUSTOMIZE_WOBY_BADGES.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.target.components.wobybadgestation ~= nil then
        local success, reason = act.target.components.wobybadgestation:CanBeginCustomization(act.doer)

        if not success then
            return false, reason
        end

        -- Silent fail for doing it in the dark.
        if CanEntitySeeTarget(act.doer, act.target) then
            act.target.components.wobybadgestation:BeginCustomization(act.doer)
        end

        return true
    end
end

ACTIONS.CUSTOMIZE_WOBY_BADGES.stroverridefn = function(act)
    return STRINGS.ACTIONS.CUSTOMIZE_WOBY_BADGES -- No scene thing name.
end

ACTIONS.WOBY_PICKUP.fn = function(act)
    if act.target == nil then
        return false
    end

    if act.doer.components.container == nil then
        return false
    end

    if act.target.components.inventoryitem ~= nil and
        (
            act.target.components.inventoryitem.canbepickedup or
            act.target.components.inventoryitem.grabbableoverridetag ~= nil and act.doer:HasTag(act.target.components.inventoryitem.grabbableoverridetag)
        ) and
        not (act.target:IsInLimbo() or
            (act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning() and act.target.components.lighter == nil) or
            (act.target.components.projectile ~= nil and act.target.components.projectile:IsThrown()))
    then
        if act.doer.components.itemtyperestrictions ~= nil and not act.doer.components.itemtyperestrictions:IsAllowed(act.target) then
            return false, "restriction"
        elseif act.target.components.container ~= nil and act.target.components.container:IsOpenedByOthers(act.doer) then
            return false, "INUSE"
        elseif (act.target.components.yotc_racecompetitor ~= nil and act.target.components.entitytracker ~= nil) then
            local trainer = act.target.components.entitytracker:GetEntity("yotc_trainer")
            if trainer ~= nil and trainer ~= act.doer then
                return false, "NOTMINE_YOTC"
            end
        elseif act.target:HasTag("heavy") then
            return false, "NO_HEAVY_LIFTING"
        end

        act.doer:PushEvent("onpickupitem", { item = act.target })

        act.doer.components.container:GiveItem(act.target)

        return true
    end
end

ACTIONS.CONTAINER_INSTALL_ITEM.strfn = function(act)
    --containerinstallableitem exists on clients too
    if act.invobject.components.containerinstallableitem then
        local containerinst = act.invobject.components.containerinstallableitem:GetValidOpenContainer(act.doer)
        if containerinst then
            local inventoryitem = act.invobject.replica.inventoryitem
            if inventoryitem and inventoryitem:IsHeldBy(containerinst) then
                return "UNINSTALL"
            end
        end
    end
end

ACTIONS.CONTAINER_INSTALL_ITEM.pre_action_cb = function(act)
    if act.doer.HUD and act.invobject.components.containerinstallableitem then
        local containerinst = act.invobject.components.containerinstallableitem:GetValidOpenContainer(act.doer)
        if containerinst then
            local inventoryitem = act.invobject.replica.inventoryitem
            if inventoryitem and not inventoryitem:IsHeldBy(containerinst) then
                local container = containerinst.replica.container
                if container == nil then
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
                elseif container.usespecificslotsforitems then
                    if container:GetSpecificSlotForItem(act.invobject) == nil then
                        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
                    end
                elseif container:IsFull() then
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
                end
            end
        end
    end
end

ACTIONS.CONTAINER_INSTALL_ITEM.fn = function(act)
    if act.invobject.components.containerinstallableitem and act.invobject.components.inventoryitem then
        local containerinst = act.invobject.components.containerinstallableitem:GetValidOpenContainer(act.doer)
        if containerinst then
            if act.invobject.components.inventoryitem:IsHeldBy(containerinst) then
                --uninstall
                local item = containerinst.components.container:RemoveItem(act.invobject, true)
                item.prevcontainer = nil
                item.prevslot = nil
                if item.components.clientpickupsoundsuppressor then
                    item.components.clientpickupsoundsuppressor:IgnoreNextPickupSound()
                end
                act.doer.components.inventory.ignoresound = true
                act.doer.components.inventory.silentfull = true
                act.doer.components.inventory:GiveItem(item, nil, act.doer:GetPosition())
                act.doer.components.inventory.silentfull = false
                act.doer.components.inventory.ignoresound = false
                if act.doer.components.inventory:GetActiveItem() == item then
                    act.doer.components.inventory:DropItem(item, true, true)
                end
            elseif containerinst.components.container.usespecificslotsforitems then
                local slot = containerinst.components.container:GetSpecificSlotForItem(act.invobject)
                if slot then
                    local item = act.invobject.components.inventoryitem:RemoveFromOwner(true)
                    local item2 = containerinst.components.container:RemoveItemBySlot(slot)
                    containerinst.components.container:GiveItem(item, slot)
                    if item2 then
                        item2.prevcontainer = nil
                        item2.prevslot = nil
                        if item2.components.clientpickupsoundsuppressor then
                            item2.components.clientpickupsoundsuppressor:IgnoreNextPickupSound()
                        end
                        act.doer.components.inventory.ignoresound = true
                        act.doer.components.inventory:GiveItem(item2, nil, act.doer:GetPosition())
                        act.doer.components.inventory.ignoresound = false
                    end
                end
            elseif not containerinst.components.container:IsFull() then
                local item = act.invobject.components.inventoryitem:RemoveFromOwner(true)
                containerinst.components.container:GiveItem(item)
            end
            return true
        end
    end
    return false
end
