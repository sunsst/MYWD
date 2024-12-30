
--[[哀悼荣耀花环]]--

-- 花环初始化逻辑
fns.ghostflower_custom_init = function(inst)
    inst:AddTag("open_top_hat")  -- 表示帽子可以作为某种容器使用
end

-- 戴上花环逻辑
fns.ghostflower_onequip = function(inst, owner)
    fns.opentop_onequip(inst, owner)  -- 定义了花环被装备时的基础逻辑
    owner:AddTag("ghost_ally")  -- 表示装备者与“幽灵”有某种关联
    owner:AddTag("ghostflower_hat_buff")  -- 只有戴了花环才能生效buff
    inst:AddTag("elixir_drinker")  -- 表示该物品具有某种“喝下药剂”的能力

    if owner and owner.components.health then
        owner.components.health.absorb = TUNING.MYWD.GHOSTFLOWER_HAT_DEF
        owner:AddTag("shielded")  -- 添加护盾标记
    end
    inst:ListenForEvent("attacked", on_ghostflower_attacked)
end

-- 摘下花环逻辑
fns.ghostflower_onunequip = function(inst, owner)
    _onunequip(inst, owner)  -- 调用一个基础的卸下事件函数_onunequip，用于清除装备帽子得到的效果
    owner:RemoveTag("ghost_ally")
    owner:RemoveTag("ghostflower_hat_buff")
    inst:RemoveTag("elixir_drinker")

    if owner and owner.components.health then
        owner.components.health.absorb = 0  -- 恢复到无护盾状态
        owner:RemoveTag("shielded")  -- 移除护盾标记
    end

    inst:RemoveEventCallback("attacked", on_ghostflower_attacked)
end

-- 恢复耐久度的回调函数
fns.on_ghostflower_recover = function(inst, owner)
    if owner.components.inventory then
        if owner.components.inventory:Has("ghostflower", 1) then  -- 检查是否有哀悼荣耀
            if inst.components.fueled then
                inst.components.fueled:SetPercent(math.min(1, inst.components.fueled:GetPercent() + TUNING.MYWD.GHOSTFLOWER_HAT_RESTORE))  -- 设置恢复后的燃料值
            end
            owner.components.inventory:ConsumeByName("ghostflower", 1)  -- 消耗一个哀悼荣耀
        end
    end
end

-- 当花环拥有防御属性时，耐久度减少逻辑
fns.on_ghostflower_attacked = function(inst, owner)
    if inst.components.fueled and owner:GetDebuff("abigail_revive_buff") ~= nil then
        inst.components.fueled:DoDelta(-TUNING.MYWD.GHOSTFLOWER_HAT_ATTACK_DAMAGE)  -- 监听攻击事件，被攻击时减少一定的燃料
    end
end

-- 耐久度用完后的回调函数
fns.on_ghostflower_remove = function(inst)
    fns.ghostflower_onunequip(inst, owner)  -- 花环消失了就相当于摘下花环
    inst:Remove()  -- 如果燃料耗尽，移除物品
end

-- 创建花环实体
fns.ghostflower = function()
    local inst = simple(fns.ghostflower_custom_init)  -- 设置创建花环的回调函数

    inst.components.floater:SetSize("med")  -- 设置物品的浮动大小为中等
    inst.components.floater:SetScale(0.68)  -- 设置物品的缩放比例

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED  -- 设置装备该物品时，理智值的恢复速度变为中等
    inst.components.equippable:SetOnEquip(fns.ghostflower_onequip)  -- 设置装备时的回调函数
    inst.components.equippable:SetOnUnequip(fns.ghostflower_onunequip)  -- 设置卸下时的回调函数

    -- 添加fueled组件来表示耐久度随时间流逝而减少
    inst:AddComponent("fueled")  -- 帽子添加了一个fueled组件，这使得它可以有一个燃料值,类似于耐久度或者使用次数
    inst.components.fueled.fueltype = FUELTYPE.USAGE  -- 表示该物品的燃料类型为使用USAGE，这通常意味着物品的燃料会随着使用而减少
    inst.components.fueled.accepting = true
    inst.components.fueled:InitializeFuelLevel(TUNING.MYWD.GHOSTFLOWER_HAT_FUEL)  -- 设置了物品的初始燃料值
    inst.components.fueled:SetDepletedFn(on_ghostflower_remove)  -- 设置了物品燃料耗尽时的回调函数

    inst.components.fueled:SetCanTakeFuelItemFn(function(inst, item, doer)
        if item.prefab = "ghostflower" then
            return true
        end
        return false
    end)

    inst:ListenForEvent("on_mourning_glory_used", fns.on_ghostflower_usage)  -- 监听哀悼荣耀的使用

    MakeHauntableLaunch(inst)  -- 可以被鬼魂作祟
    return inst
end

AddPrefabtPostInit("hats", function(self)
    local old_MakeHat = self.MakeHat

    local custom_MakeHat = function(name)

        if old_MakeHat then
            old_MakeHat(name)
        end
    end

    self.MakeHat = custom_MakeHat
end)