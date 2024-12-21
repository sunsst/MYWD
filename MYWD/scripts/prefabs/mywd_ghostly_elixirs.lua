-- 源代码：scripts\prefabs\ghostly_elixirs.lua

---------------------------------------------------------------------------------------- Jowwar up
local potion_tunings =
{
    -- 月亮药剂
    ghostlyelixir_moon =
    {
        -- 药剂效果的更新频率
        TICK_RATE = TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_MOON_TICK_TIME,

        -- 使用药剂，可修改为事件
        ONAPPLY = function(inst, target)
            if not target.components.planardamage then
                target:AddComponent("planardamage")
            end

            if not target.components.planardefense then
                target:AddComponent("planardefense")
            end

            target.components.planardamage:SetBaseDamage(TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_MOON_PLANAR_DAMAGE)
            target.components.planardefense:SetBaseDefense(TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_MOON_PLANAR_DEFENSE)
        end,

        -- 移除药剂效果
        ONDETACH = function(inst, target)
            if target.components.planardamage then
                target.components.planardamage:SetBaseDamage(0)
                -- target.components.planardamage:SetBaseDamage(
                --     target.components.planardamage:GetBaseDamage() - TUNING.MYWD.GHOSTLYELIXIR_MOON_PLANAR_DAMAGE)
            end

            if target.components.planardefense then
                target.components.planardefense:SetBaseDefense(0)
                -- target.components.planardamage:SetBaseDefense(
                --     target.components.planardamage:GetBaseDefense() - TUNING.MYWD.GHOSTLYELIXIR_MOON_PLANAR_DEFENSE)
            end
        end,

        -- TICK_FN = function(inst, target) target.components.health:DoDelta(TUNING.GHOSTLYELIXIR_SLOWREGEN_HEALING, true, inst.prefab) end,  -- 处理药剂的效果
        DURATION = TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_MOON_DURATION,  -- 药剂持续时间
        FLOATER = { "small", 0.15, 0.55 },  -- 水中浮动效果
        fx = "ghostlyelixir_fastregen_fx",
        dripfx = "ghostlyelixir_fastregen_dripfx",
    },

    -- 暗影药剂
    ghostlyelixir_shadow =
    {
        -- 药剂效果的更新频率
        TICK_RATE = TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_SHADOW_TICK_TIME,

        -- 使用药剂，可修改为事件
        ONAPPLY = function(inst, target)
            if not target.components.planardamage then
                target:AddComponent("planardamage")
            end

            if not target.components.planardefense then
                target:AddComponent("planardefense")
            end

            target.components.planardamage:SetBaseDamage(TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_SHADOW_PLANAR_DAMAGE)
            target.components.planardefense:SetBaseDefense(TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_SHADOW_PLANAR_DEFENSE)
        end,

        -- 移除药剂效果
        ONDETACH = function(inst, target)
            if target.components.planardamage then
                target.components.planardamage:SetBaseDamage(0)
                -- target.components.planardamage:SetBaseDamage(
                --     target.components.planardamage:GetBaseDamage() - TUNING.MYWD.GHOSTLYELIXIR_MOON_PLANAR_DAMAGE)
            end

            if target.components.planardefense then
                target.components.planardefense:SetBaseDefense(0)
                -- target.components.planardamage:SetBaseDefense(
                --     target.components.planardamage:GetBaseDefense() - TUNING.MYWD.GHOSTLYELIXIR_MOON_PLANAR_DEFENSE)
            end
        end,

        -- TICK_FN = function(inst, target) target.components.health:DoDelta(TUNING.GHOSTLYELIXIR_SLOWREGEN_HEALING, true, inst.prefab) end,  -- 处理药剂的效果
        DURATION = TUNING.MYWD_ELIXIRS.GHOSTLYELIXIR_SHADOW_DURATION,  -- 药剂持续时间
        FLOATER = { "small", 0.15, 0.55 },  -- 水中浮动效果
        fx = "ghostlyelixir_fastregen_fx",
        dripfx = "ghostlyelixir_fastregen_dripfx",
    }
}
----------------------------------------------------------------------------- Jowwar down

-- 使用药剂，同时去除其他药剂效果
local function DoApplyElixir(inst, giver, target)
    return target:AddDebuff("elixir_buff", inst.buff_prefab, nil, nil, function()
        local cur_buff = target:GetDebuff("elixir_buff")
        if cur_buff ~= nil and cur_buff.prefab ~= inst.buff_prefab then
            target:RemoveDebuff("elixir_buff")
        end
    end)
end

-- 通用生成药剂实体
local function potion_fn(anim, potion_tunings, buff_prefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()  -- 添加变换组件，位置、旋转、缩放
    inst.entity:AddAnimState()  -- 添加药剂的动画状态管理
    inst.entity:AddNetwork()  -- 添加网络组件，用于多人游戏中同步

    MakeInventoryPhysics(inst)  -- 添加物理引擎

    inst.AnimState:SetBank("ghostly_elixirs")  -- 指定药剂的图像资源包
    inst.AnimState:SetBuild("mywd_ghostly_elixirs")  -- 指定药剂的动画数据
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim
    inst.scrapbook_specialinfo = "GHOSTLYELIXER" .. string.upper(anim)

    if potion_tunings.FLOATER ~= nil then
        MakeInventoryFloatable(inst, potion_tunings.FLOATER[1], potion_tunings.FLOATER[2], potion_tunings.FLOATER[3])
    else
        MakeInventoryFloatable(inst)
    end

    inst:AddTag("ghostlyelixir")

    inst.entity:SetPristine()  -- 标记该实体只用于客户端和服务器同步

    if not TheWorld.ismastersim then
        return inst
    end

    inst.buff_prefab = buff_prefab
    inst.potion_tunings = potion_tunings

    inst:AddComponent("inspectable")  -- 检查组件
    inst:AddComponent("inventoryitem")  -- 物品组件
    inst:AddComponent("stackable")  -- 堆叠组件

    inst:AddComponent("ghostlyelixir")
    inst.components.ghostlyelixir.doapplyelixerfn = DoApplyElixir

    -- MYWD:物品栏图集
    inst.components.inventoryitem.atlasname = "images/mywd_icon.xml"



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

-- 定时触发的函数
local function buff_OnTick(inst, target)
    if target.components.health ~= nil and
        not target.components.health:IsDead() then
        inst.potion_tunings.TICK_FN(inst, target)
    else
        inst.components.debuff:Stop()
    end
end

-- buff触发特效
local function buff_DripFx(inst, target)
    if not target.inlimbo and not target.sg:HasStateTag("busy") then
        SpawnPrefab(inst.potion_tunings.dripfx).Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

-- buff持续特效
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
        -- MYWD:修改为自己的动画文件
        Asset("ANIM", "anim/mywd_ghostly_elixirs.zip"),
        Asset("ANIM", "anim/abigail_buff_drip.zip"),
        Asset("ATLAS", "images/mywd_icon.xml")
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

-- 添加药剂，输入药剂标识名，药剂动画名
AddPotion(potions, "moon", "moon")

return unpack(potions)
