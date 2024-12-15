-- 美梦药剂改自万金油(prefabs\skilltree_wilson.lua)

local potion_tunings =
{
    ghostlyelixir_dream =
    {
        ONAPPLY = function(inst, target)
            if target.components.planardamage == nil then
                target:AddComponent("planardamage")
            end
            if target.components.planardefense == nil then
                target:AddComponent("planardefense")
            end

            target.components.planardamage:SetBaseDamage(TUNING.MYWD_GHOSTLYELIXIR_DREAM_PLANARDAMAGE)
            target.components.planardefense:SetBaseDefense(TUNING.MYWD_GHOSTLYELIXIR_DREAM_PLANARDEFENSE)
        end,
        ONDETACH = function(inst, target)
            if not target:IsValid() then return end

            if target.components.planardamage ~= nil then
                target.components.planardamage:SetBaseDamage(0)
            end

            if target.components.planardefense ~= nil then
                target.components.planardefense:SetBaseDefense(0)
            end
        end,
        DURATION = TUNING.MYWD_GHOSTLYELIXIR_DREAM_DURATION,
        FLOATER = { "small", 0.1, 0.5 },
        fx = "ghostlyelixir_attack_fx",
        dripfx = "ghostlyelixir_attack_dripfx",
    },
}

local function DoApplyElixir(inst, giver, target)
    return target:AddDebuff("elixir_buff", inst.buff_prefab, nil, nil, function()
        local cur_buff = target:GetDebuff("elixir_buff")
        if cur_buff ~= nil and cur_buff.prefab ~= inst.buff_prefab then
            target:RemoveDebuff("elixir_buff")
        end
    end)
end

local SPEED_HAUNT_MULTIPLIER_NAME = "haunted_speedpot"
local function speed_potion_haunt_remove_buff(inst)
    if inst._haunted_speedpot_task ~= nil then
        inst._haunted_speedpot_task:Cancel()
        inst._haunted_speedpot_task = nil
    end
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, SPEED_HAUNT_MULTIPLIER_NAME)
    inst:RemoveEventCallback("ms_respawnedfromghost", speed_potion_haunt_remove_buff)
end

local function speed_potion_haunt(inst, haunter)
    Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    if haunter:HasTag("playerghost") then
        haunter.components.locomotor:SetExternalSpeedMultiplier(haunter, SPEED_HAUNT_MULTIPLIER_NAME,
            TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT)
        if haunter._haunted_speedpot_task ~= nil then
            haunter._haunted_speedpot_task:Cancel()
            haunter._haunted_speedpot_task = nil
        end
        haunter:ListenForEvent("ms_respawnedfromghost", speed_potion_haunt_remove_buff)
        haunter._haunted_speedpot_task = haunter:DoTaskInTime(TUNING.GHOSTLYELIXIR_SPEED_PLAYER_GHOST_DURATION,
            speed_potion_haunt_remove_buff)
    end

    return true
end

local function potion_fn(anim, potion_tunings, buff_prefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ghostly_elixirs")
    inst.AnimState:SetBuild("mywd_ghostly_elixirs")
    inst.AnimState:PlayAnimation(anim, true)
    inst.scrapbook_anim = anim
    inst.scrapbook_specialinfo = "GHOSTLYELIXER" .. string.upper(anim)

    if potion_tunings.FLOATER ~= nil then
        MakeInventoryFloatable(inst, potion_tunings.FLOATER[1], potion_tunings.FLOATER[2], potion_tunings.FLOATER[3])
    else
        MakeInventoryFloatable(inst)
    end

    inst:AddTag("ghostlyelixir")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.buff_prefab = buff_prefab
    inst.potion_tunings = potion_tunings

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("ghostlyelixir")
    inst.components.ghostlyelixir.doapplyelixerfn = DoApplyElixir
    inst.components.inventoryitem.atlasname = "images/mywd_ghostly_elixirs.xml"

    -- Players can haunt the speed potion to get a temporary speed boost.
    -- Shh it's a secret.
    if potion_tunings.speed_hauntable then
        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
        inst.components.hauntable:SetOnHauntFn(speed_potion_haunt)
    else
        MakeHauntableLaunch(inst)
    end

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    return inst
end

local function buff_OnTick(inst, target)
    if target.components.health ~= nil and
        not target.components.health:IsDead() then
        inst.potion_tunings.TICK_FN(inst, target)
    else
        inst.components.debuff:Stop()
    end
end

local function buff_DripFx(inst, target)
    if not target.inlimbo and not target.sg:HasStateTag("busy") then
        SpawnPrefab(inst.potion_tunings.dripfx).Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function buff_OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading

    if inst.potion_tunings.ONAPPLY ~= nil then
        inst.potion_tunings.ONAPPLY(inst, target)
    end

    if inst.potion_tunings.TICK_RATE ~= nil then
        inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
    end
    inst.driptask = inst:DoPeriodicTask(TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY, buff_DripFx,
        TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY * 0.25, target)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    if inst.potion_tunings.fx ~= nil and not target.inlimbo then
        local fx = SpawnPrefab(inst.potion_tunings.fx)
        fx.entity:SetParent(target.entity)
    end
end

local function buff_OnTimerDone(inst, data)
    if data.name == "decay" then
        inst.components.debuff:Stop()
    end
end

local function buff_OnExtended(inst, target)
    if (inst.components.timer:GetTimeLeft("decay") or 0) < inst.potion_tunings.DURATION then
        inst.components.timer:StopTimer("decay")
        inst.components.timer:StartTimer("decay", inst.potion_tunings.DURATION)
    end
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
    end

    if inst.potion_tunings.fx ~= nil and not target.inlimbo then
        local fx = SpawnPrefab(inst.potion_tunings.fx)
        fx.entity:SetParent(target.entity)
    end
end

local function buff_OnDetached(inst, target)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if inst.driptask ~= nil then
        inst.driptask:Cancel()
        inst.driptask = nil
    end
    if inst.potion_tunings.ONDETACH ~= nil then
        inst.potion_tunings.ONDETACH(inst, target)
    end
    inst:Remove()
end

local function buff_fn(tunings, dodelta_fn)
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst.potion_tunings = tunings

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("decay", tunings.DURATION)
    inst:ListenForEvent("timerdone", buff_OnTimerDone)

    return inst
end

local function AddPotion(potions, name, anim)
    local potion_prefab = "ghostlyelixir_" .. name
    local buff_prefab = potion_prefab .. "_buff"

    local assets = {
        Asset("ANIM", "anim/mywd_ghostly_elixirs.zip"),
        Asset("ANIM", "anim/abigail_buff_drip.zip"),
        Asset("ATLAS", "images/mywd_ghostly_elixirs.xml")
    }
    local prefabs = {
        buff_prefab,
        potion_tunings[potion_prefab].fx,
        potion_tunings[potion_prefab].dripfx,
    }
    if potion_tunings[potion_prefab].shield_prefab ~= nil then
        table.insert(prefabs, potion_tunings[potion_prefab].shield_prefab)
    end

    local function _buff_fn() return buff_fn(potion_tunings[potion_prefab]) end
    local function _potion_fn() return potion_fn(anim, potion_tunings[potion_prefab], buff_prefab) end

    table.insert(potions, Prefab(potion_prefab, _potion_fn, assets, prefabs))
    table.insert(potions, Prefab(buff_prefab, _buff_fn))
end


local potions = {}
AddPotion(potions, "dream", "dream")

return unpack(potions)
