--DSV uses 4 but ignores physics radius
local NO_TAGS_NO_PLAYERS = { "INLIMBO", "notarget", "noattack", "wall", "player", "companion", "playerghost" }
local COMBAT_TARGET_TAGS = { "_combat" }


local potion_tunings =
{
    -- MYWD: 添加了我们自己的暗影和月亮药
    ghostlyelixir_mywd_shadow =
    {
        ONAPPLY = function(inst, target)
            if target and target:IsValid() then
                target.components.mywd_shadowab:ToGetBuff()
            end
        end,
        ONDETACH = function(inst, target)
            if target and target:IsValid() then
                target.components.mywd_shadowab:ToNormal()
            end
        end,
        DURATION = TUNING.MYWD.GHOSTLYELIXIR_MYWD_SHADOW_DURATION,
        FLOATER = { "small", 0.1, 0.5 },
        fx = "ghostlyelixir_attack_fx",
        dripfx = "ghostlyelixir_attack_dripfx",
    },
    ghostlyelixir_mywd_moon =
    {

        ONAPPLY = function(inst, target)
            if target and target:IsValid() then
                target.components.planardamage:SetBaseDamage(target.components.planardamage:GetBaseDamage() +
                    TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DAMAGE)
                target.components.planardefense:SetBaseDefense(target.components.planardefense:GetBaseDefense() +
                    TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DEFENSE)
            end
        end,
        ONDETACH = function(inst, target)
            if target and target:IsValid() then
                target.components.planardamage:SetBaseDamage(target.components.planardamage:GetBaseDamage() -
                    TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DAMAGE)
                target.components.planardefense:SetBaseDefense(target.components.planardefense:GetBaseDefense() -
                    TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DEFENSE)
            end
        end,
        DURATION = TUNING.MYWD.GHOSTLYELIXIR_MYWD_MOON_DURATION,
        FLOATER = { "small", 0.1, 0.5 },
        fx = "ghostlyelixir_speed_fx",
        dripfx = "ghostlyelixir_speed_dripfx",
    },
}

local function DoApplyElixir(inst, giver, target)
    local buff_type = "elixir_buff"

    if inst.potion_tunings.super_elixir then
        buff_type = "super_elixir_buff"
    end

    local buff = target:AddDebuff(buff_type, inst.buff_prefab, nil, nil, function()
        local cur_buff = target:GetDebuff(buff_type)
        if cur_buff ~= nil and cur_buff.prefab ~= inst.buff_prefab then
            target:RemoveDebuff(buff_type)
        end
    end)

    if buff then
        local new_buff = target:GetDebuff(buff_type)
        new_buff:buff_skill_modifier_fn(giver, target)
        return buff
    end
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

    -- MYWD:设置自己的动画
    inst.AnimState:SetBank("mywd_ghostly_elixirs")
    inst.AnimState:SetBuild("mywd_ghostly_elixirs")
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim
    inst.scrapbook_specialinfo = "GHOSTLYELIXER" .. string.upper(anim)
    inst.elixir_buff_type = anim

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

    -- MYWD:物品栏图集
    inst.components.inventoryitem.atlasname = resolvefilepath("images/mywd_icon.xml")

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
        if target:HasTag("player") then
            inst.potion_tunings.TICK_FN_PLAYER(inst, target)
        else
            inst.potion_tunings.TICK_FN(inst, target)
        end
    else
        inst.components.debuff:Stop()
    end
end

local function buff_DripFx(inst, target)
    local prefab = inst.potion_tunings.dripfx
    if target:HasTag("player") then
        prefab = inst.potion_tunings.dripfx_player
    end

    if not target.inlimbo and not target.sg:HasStateTag("busy") then
        SpawnPrefab(prefab).Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function buff_OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading

    if target:HasTag("player") then
        if inst.potion_tunings.ONAPPLY_PLAYER ~= nil then
            inst.potion_tunings.ONAPPLY_PLAYER(inst, target)
        end
    else
        if inst.potion_tunings.ONAPPLY ~= nil then
            inst.potion_tunings.ONAPPLY(inst, target)
        end
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
        local prefab = inst.potion_tunings.fx
        if target:HasTag("player") then
            prefab = inst.potion_tunings.fx_player
        end

        local fx = SpawnPrefab(prefab)
        fx.entity:SetParent(target.entity)
    end
end

local function buff_OnTimerDone(inst, data)
    if data.name == "decay" then
        inst.components.debuff:Stop()
    end
end

local function buff_OnExtended(inst, target)
    local duration = inst.potion_tunings.DURATION
    if target:HasTag("player") then
        duration = inst.potion_tunings.DURATION_PLAYER
    end

    if (inst.components.timer:GetTimeLeft("decay") or 0) < duration then
        inst.components.timer:StopTimer("decay")
        inst.components.timer:StartTimer("decay", duration)
    end
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
    end

    if inst.potion_tunings.fx ~= nil and not target.inlimbo and not target:HasTag("player") then
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

    if target:HasTag("player") then
        if inst.potion_tunings.ONDETACH_PLAYER ~= nil then
            inst.potion_tunings.ONDETACH_PLAYER(inst, target)
        end
    else
        if inst.potion_tunings.ONDETACH ~= nil then
            inst.potion_tunings.ONDETACH(inst, target)
        end
    end
    inst:Remove()
end

local function buff_skill_modifier_fn(inst, doer, target)
    local duration_mult = 1

    if inst.potion_tunings.skill_modifier_long_duration and doer.components.skilltreeupdater:IsActivated("wendy_potion_duration") then
        duration_mult = duration_mult + TUNING.SKILLS.WENDY.POTION_DURATION_MOD
    end

    local duration = inst.potion_tunings.DURATION
    if target:HasTag("player") then
        duration = inst.potion_tunings.DURATION_PLAYER
    end

    inst.components.timer:StopTimer("decay")
    inst.components.timer:StartTimer("decay", duration * duration_mult)
end

local function buff_fn(tunings, dodelta_fn)
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.buff_skill_modifier_fn = buff_skill_modifier_fn
    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst.potion_tunings = tunings

    inst:AddTag("CLASSIFIED")

    local debuff = inst:AddComponent("debuff")
    debuff:SetAttachedFn(buff_OnAttached)
    debuff:SetDetachedFn(buff_OnDetached)
    debuff:SetExtendedFn(buff_OnExtended)
    debuff.keepondespawn = true

    local timer = inst:AddComponent("timer")
    timer:StartTimer("decay", tunings.DURATION)
    inst:ListenForEvent("timerdone", buff_OnTimerDone)

    return inst
end

local function AddPotion(potions, name, anim, extra_assets)
    local potion_prefab = "ghostlyelixir_" .. name
    local buff_prefab = potion_prefab .. "_buff"

    local assets = {
        -- MYWD:修改为自己的动画文件
        Asset("ANIM", resolvefilepath("anim/mywd_ghostly_elixirs.zip")),
        Asset("ATLAS", resolvefilepath("images/mywd_icon.xml")),

        Asset("ANIM", "anim/abigail_buff_drip.zip"),
        -- Asset("ANIM", "anim/player_elixir_buff_drip.zip"),
        -- Asset("ANIM", "anim/player_vial_fx.zip"),
    }
    if extra_assets then ConcatArrays(assets, extra_assets) end

    local prefabs = {
        buff_prefab,
        potion_tunings[potion_prefab].fx,
        potion_tunings[potion_prefab].dripfx,
        potion_tunings[potion_prefab].fx_player,
        potion_tunings[potion_prefab].dripfx_player,
        "ghostvision_buff",
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
AddPotion(potions, "mywd_moon", "mywd_moon")
AddPotion(potions, "mywd_shadow", "mywd_shadow")

return unpack(potions)
