--DSV uses 4 but ignores physics radius
local NO_TAGS_NO_PLAYERS = { "INLIMBO", "notarget", "noattack", "wall", "player", "companion", "playerghost" }
local COMBAT_TARGET_TAGS = { "_combat" }

local potion_tunings =
{
    -- 亡者补药
	ghostlyelixir_slowregen =
	{
		TICK_RATE = TUNING.MYWD.GHOSTLYELIXIR_SLOWREGEN_TICK_TIME,  -- 药剂效果的更新频率
		ONAPPLY = function(inst, target)  -- 使用药剂
            target:PushEvent("startsmallhealthregen", inst)
        end,
		TICK_FN = function(inst, target)  -- 处理药剂的效果
            target.components.health:DoDelta(TUNING.MYWD.GHOSTLYELIXIR_SLOWREGEN_HEALING, true, inst.prefab)
        end,
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_SLOWREGEN_DURATION,  -- 药剂的持续时间
        FLOATER = {"small", 0.15, 0.55},  -- 浮动效果的范围
		fx = "ghostlyelixir_slowregen_fx",  -- 药剂持续特效
		dripfx = "ghostlyelixir_slowregen_dripfx",  -- 药剂施加特效
        skill_modifier_long_duration = true,  -- 技能修改药剂的持续时间

        -- 玩家药剂效果
        DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_SLOWREGEN_DURATION,
		TICK_FN_PLAYER = function(inst, target)
			target.components.health:DoDelta(TUNING.MYWD.GHOSTLYELIXIR_PLAYER_SLOWREGEN_HEALING, true, inst.prefab)
		end,
		fx_player = "ghostlyelixir_player_slowregen_fx",
		dripfx_player = "ghostlyelixir_player_slowregen_dripfx",
        buff_name = "abigail_slowregen_buff",
	},
	-- 灵魂万灵药
	ghostlyelixir_fastregen =
	{
		TICK_RATE = TUNING.MYWD.GHOSTLYELIXIR_FASTREGEN_TICK_TIME,
		ONAPPLY = function(inst, target)
            target:PushEvent("starthealthregen", inst)
        end,
		TICK_FN = function(inst, target)
            target.components.health:DoDelta(TUNING.MYWD.GHOSTLYELIXIR_FASTREGEN_HEALING, true, inst.prefab)
        end,
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_FASTREGEN_DURATION,
        FLOATER = {"small", 0.15, 0.55},
		fx = "ghostlyelixir_fastregen_fx",
		dripfx = "ghostlyelixir_fastregen_dripfx",
        skill_modifier_long_duration = false,

        -- 玩家药剂效果
		ONAPPLY_PLAYER = function(inst, target)
			target:PushEvent("starthealthregen", inst)
		end,
		TICK_FN_PLAYER = function(inst, target)
			target.components.health:DoDelta(TUNING.MYWD.GHOSTLYELIXIR_PLAYER_FASTREGEN_HEALING, true, inst.prefab)
		end,
		DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_FASTREGEN_DURATION,
		fx_player = "ghostlyelixir_player_fastregen_fx",
		dripfx_player = "ghostlyelixir_player_fastregen_dripfx",
        buff_name = "abigail_fastregen_buff",
	},
	-- 夜影万金油
	ghostlyelixir_attack =
	{
		ONAPPLY = function(inst, target)
			if target.UpdateDamage ~= nil then
				target:UpdateDamage()
			end
		end,
		ONDETACH = function(inst, target)
			if target:IsValid() and target.UpdateDamage ~= nil then
				target:UpdateDamage()
			end
		end,
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_DAMAGE_DURATION,
        FLOATER = {"small", 0.1, 0.5},
		fx = "ghostlyelixir_attack_fx",
		dripfx = "ghostlyelixir_attack_dripfx",
        skill_modifier_long_duration = true,

        -- 玩家药剂效果
		ONAPPLY_PLAYER = function(inst, target)
			if not target:HasDebuff("ghostvision_buff") then
				target.components.talker:Say(GetString(target, "ANNOUNCE_ELIXIR_GHOSTVISION"))
			end
			target:AddDebuff("ghostvision_buff","ghostvision_buff")
		end,
		ONDETACH_PLAYER = function(inst, target)
			target:RemoveDebuff("ghostvision_buff")
		end,
		DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_DAMAGE_DURATION,
		fx_player = "ghostlyelixir_player_attack_fx",
		dripfx_player = "ghostlyelixir_player_attack_dripfx",
        buff_name = "abigail_attack_buff",
	},
	-- 强健精油
	ghostlyelixir_speed =
	{
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_SPEED_DURATION,
		ONAPPLY = function(inst, target)
            target.components.locomotor:SetExternalSpeedMultiplier(inst, "ghostlyelixir", TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT)
        end,
        FLOATER = {"small", 0.2, 0.4},
		fx = "ghostlyelixir_speed_fx",
		dripfx = "ghostlyelixir_speed_dripfx",
		speed_hauntable = true,
        skill_modifier_long_duration = true,

        -- 玩家药剂效果
		DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_SPEED_DURATION,
		ONAPPLY_PLAYER = function(inst, target)
			target.components.talker:Say(GetString(target, "ANNOUNCE_ELIXIR_PLAYER_SPEED"))
			target:AddTag("vigorbuff")
			target.components.locomotor:EnableGroundSpeedMultiplier(false)
			target.components.locomotor:EnableGroundSpeedMultiplier(true)
		end,
		ONDETACH_PLAYER = function(inst, target)
			target:RemoveTag("vigorbuff")
		end,
		fx_player = "ghostlyelixir_player_speed_fx",
		dripfx_player = "ghostlyelixir_player_speed_dripfx",
        buff_name = "abigail_speed_buff",
	},
	-- 不屈药剂
	ghostlyelixir_shield =
	{
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_SHIELD_DURATION,
        FLOATER = {"small", 0.15, 0.8},
		shield_prefab = "abigailforcefieldbuffed",
		fx = "ghostlyelixir_shield_fx",
		dripfx = "ghostlyelixir_shield_dripfx",
        skill_modifier_long_duration = true,

        -- 玩家药剂效果
		DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_SHIELD_DURATION,
		ONAPPLY_PLAYER = function(inst, target)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:SetModifier(target, TUNING.GHOSTLYELIXIR_PLAYER_SHIELD_REDUCTION, "forcefield")
			end
		    target:ListenForEvent("attacked", onattacked_shield)
		end,
		ONDETACH_PLAYER = function(inst, target)
			target:RemoveEventCallback("attacked", onattacked_shield)
			if target.components.health ~= nil then
				target.components.health.externalreductionmodifiers:RemoveModifier(target, "forcefield")
			end
		end,
		fx_player = "ghostlyelixir_player_shield_fx",
		dripfx_player = "ghostlyelixir_player_shield_dripfx",
        buff_name = "abigail_shield_buff",
	},
	-- 蒸馏复仇
	ghostlyelixir_retaliation =
	{
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_RETALIATION_DURATION,
        FLOATER = {"small", 0.2, 0.4},
		fx = "ghostlyelixir_retaliation_fx",
		dripfx = "ghostlyelixir_retaliation_dripfx",
        skill_modifier_long_duration = true,

        -- 玩家药剂效果
		DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_SHIELD_DURATION,
		ONAPPLY_PLAYER = function(inst, target)
		    target:ListenForEvent("attacked", onattacked_shield)
		end,
		ONDETACH_PLAYER = function(inst, target)
			target:RemoveEventCallback("attacked", onattacked_shield)
		end,
		playerreatliate=true,
		fx_player = "ghostlyelixir_player_retaliation_fx",
		dripfx_player = "ghostlyelixir_player_retaliation_dripfx",
        buff_name = "abigail_retaliation_buff",
	},
    -- 回忆灵药
    ghostlyelixir_revive =
	{
		DURATION = TUNING.MYWD.GHOSTLYELIXIR_REVIVE_DURATION,
        FLOATER = {"small", 0.2, 0.4},
		ONAPPLY = function(inst, target)
			if target.components.follower.leader and target.components.follower.leader.components.ghostlybond then
				target.components.follower.leader.components.ghostlybond:SetBondLevel(3)
			end
		end,
		fx = "ghostlyelixir_retaliation_fx",
		dripfx = "ghostlyelixir_retaliation_dripfx",
		skill_modifier_long_duration = true,

		-- 玩家药剂效果
		DURATION_PLAYER = TUNING.MYWD.GHOSTLYELIXIR_PLAYER_REVIVE_DURATION,
		ONAPPLY_PLAYER = function(inst, target)
			target.components.talker:Say(GetString(target, "ANNOUNCE_ELIXIR_BOOSTED"))
		end,
		fx_player = "ghostlyelixir_player_retaliation_fx",
		dripfx_player = "ghostlyelixir_player_retaliation_dripfx",
        buff_name = "abigail_revive_buff",
	},
    -- 月亮药剂
    ghostlyelixir_lunar =
    {
        ONAPPLY = function(inst, target)
            if target ~= nil and target:IsValid() and target.components.planardamage ~= nil then
                target.components.planardamage:SetBaseDamage(target.components.planardamage:GetBaseDamage() +
                    TUNING.MYWD.GHOSTLYELIXIR_MOON_DAMAGE)
                target.components.planardefense:SetBaseDefense(target.components.planardefense:GetBaseDefense() +
                    TUNING.MYWD.GHOSTLYELIXIR_MOON_DEFENSE)
            end
        end,
        ONDETACH = function(inst, target)
            if target ~= nil and target:IsValid() and target.components.planardamage ~= nil then
                target.components.planardamage:SetBaseDamage(target.components.planardamage:GetBaseDamage() -
                    TUNING.MYWD.GHOSTLYELIXIR_MOON_DAMAGE)
                target.components.planardefense:SetBaseDefense(target.components.planardefense:GetBaseDefense() -
                    TUNING.MYWD.GHOSTLYELIXIR_MOON_DEFENSE)
            end
        end,
        DURATION = TUNING.MYWD.GHOSTLYELIXIR_MOON_DURATION,
        FLOATER = { "small", 0.2, 0.4 },
        fx = "ghostlyelixir_lunar_fx",
        dripfx = "ghostlyelixir_lunar_dripfx",
        buff_name = "abigail_lunar_buff",
        skill_modifier_long_duration = true,
		super_elixir = true,
    },
    -- 暗影药剂
    ghostlyelixir_shadow =
    {
        ONAPPLY = function(inst, target)
            if target ~= nil and target:IsValid() and target.components.planardamage ~= nil then
                target.components.planardamage:SetBaseDamage(target.components.planardamage:GetBaseDamage() +
                    TUNING.MYWD.GHOSTLYELIXIR_MOON_DAMAGE)
                target.components.planardefense:SetBaseDefense(target.components.planardefense:GetBaseDefense() +
                    TUNING.MYWD.GHOSTLYELIXIR_MOON_DEFENSE)
            end
        end,
        ONDETACH = function(inst, target)
            if target ~= nil and target:IsValid() and target.components.planardamage ~= nil then
                target.components.planardamage:SetBaseDamage(target.components.planardamage:GetBaseDamage() +
                    TUNING.MYWD.GHOSTLYELIXIR_SHADOW_DAMAGE)
                target.components.planardefense:SetBaseDefense(target.components.planardefense:GetBaseDefense() +
                    TUNING.MYWD.GHOSTLYELIXIR_SHADOW_DEFENSE)
            end
        end,
        DURATION = TUNING.MYWD.GHOSTLYELIXIR_SHADOW_DURATION,
        FLOATER = { "small", 0.2, 0.4 },
        fx = "ghostlyelixir_shadow_fx",
        dripfx = "ghostlyelixir_shadow_dripfx",
        buff_name = "abigail_shadow_buff",
        skill_modifier_long_duration = true,
		super_elixir = true,
    },
}

-- 获取已经存在的药剂buff
local function GetElixirBuff(inst, target)
    -- 全部buff检查一遍
    all_buff = {
        "abigail_slowregen_buff",  -- 亡者补药
        "abigail_fastregen_buff",  -- 灵魂万灵药
        "abigail_attack_buff",  -- 夜影万金油
        "abigail_speed_buff",  -- 强健精油
        "abigail_shield_buff",  -- 不屈药剂
        "abigail_retaliation_buff",  -- 蒸馏复仇
        "abigail_revive_buff",  -- 回忆灵药
    },

    local exist_buff = {},  -- 存储已有的buff
    for key, buff_type in ipairs(all_buff) do
        if target:GetDebuff(buff_type) ~= nil then
            table.insert(exist_buff, buff_type)
        end
    end

    return exist_buff
end

-- 检查新buff的情况，如果已经存在两个旧buff，且新的buff和旧的两个buff不一样，则去掉更旧的buff
local function CheckElixirBuff(buff_type, exist_buff)
    if #exist_buff == 2 and exist_buff[1] ~= buff_type and exist_buff[2] ~= buff_type then
        local buff_1 = target:GetDebuff(exist_buff[1])
        if target:HasTag("player") then
            local duration_1 = buff_1.potion_tunings.DURATION_PLAYER
        else
            local duration_1 = buff_1.potion_tunings.DURATION
        end
        local elapsed_time_1 = duration_1 - buff_1.components.timer:GetTimeLeft("decay")

        local buff_2 = target:GetDebuff(exist_buff[2])
        if target:HasTag("player") then
            local duration_2 = buff_2.potion_tunings.DURATION_PLAYER
        else
            local duration_2 = buff_2.potion_tunings.DURATION
        end
        local elapsed_time_2 = duration_2 - buff_2.components.timer:GetTimeLeft("decay")

        local older_buff_type =  exist_buff[1]
        if elapsed_time_1 < elapsed_time_2 then
            older_buff_type =  exist_buff[2]
        end
        
        target:RemoveDebuff(older_buff_type)
    end
end

-- 使用药剂，普通药剂可以同时生效两种，普通药剂和阵营药剂共存
local function DoApplyElixir(inst, giver, target)
	-- local buff_type = inst.buff_name,
    local buff_type = "super_elixir_buff"

    -- 检查普通药剂buff是否存在，若不存在且已存在两种药剂buff，则移除旧的普通药剂buff
	if not inst.potion_tunings.super_elixir then
		local exist_buff = GetElixirBuff(inst, target)
        buff_type = inst.buff_name
        CheckElixirBuff(buff_type, exist_buff)
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

-- 造成反伤
local onattacked_shield = function(inst)
	local fx = SpawnPrefab("elixir_player_forcefield")  -- 生成护盾特效实体
	inst:AddChild(fx)  -- 对应药剂添加跟随的特效实体
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/shield/on")  -- 护盾音效

    -- 没有药剂buff时，直接返回
	local debuff = inst:GetDebuff("elixir_buff")
	if not debuff then
		return
	end

	if debuff.potion_tunings.playerreatliate then  -- 检查药剂配置中是否启用了反击机制
		local hitrange = 5  -- 反击的作用范围
		local damage = 20  -- 反击的伤害值
		debuff.ignore = {}  -- 用于记录已经反击过的目标，避免重复伤害

	    local x, y, z = inst.Transform:GetWorldPosition()  -- 获取温蒂的位置

        -- 在角色周围查找所有符合特定标签的实体，hitrange为搜索半径，COMBAT_TARGET_TAGS表示目标可攻击，NO_TAGS_NO_PLAYERS排除特定标签的实体（如玩家）
		for i, v in ipairs(TheSim:FindEntities(x, y, z, hitrange, COMBAT_TARGET_TAGS, NO_TAGS_NO_PLAYERS)) do
			if not debuff.ignore[v] and  -- 该目标未被反击过
				v:IsValid() and  -- 目标有效且未被移除
				v.entity:IsVisible() and  -- 目标在场景中可见
				v.components.combat ~= nil then  -- 目标有战斗组件（可以被攻击）
				local range = hitrange + v:GetPhysicsRadius(0)  -- 计算作用范围
				if v:GetDistanceSqToPoint(x, y, z) < range * range then  -- 如果目标位于反伤范围之内
					if inst.owner ~= nil and not inst.owner:IsValid() then  -- 确保温蒂存在才能触发反伤
						inst.owner = nil
					end
					if inst.owner ~= nil then
						if inst.owner.components.combat ~= nil and  -- 玩家拥有攻击组件
							inst.owner.components.combat:CanTarget(v) and  -- 目标是否可以攻击
							not inst.owner.components.combat:IsAlly(v)  -- 目标是否是盟友
						then
							debuff.ignore[v] = true  -- 将目标记录在debuff.ignore表中
							local retaliation = SpawnPrefab("abigail_retaliation")  -- 生成反击特效
							retaliation:SetRetaliationTarget(v)  -- 将特效的目标设置为当前实体
							--V2C: wisecracks make more sense for being pricked by picking
							--v:PushEvent("thorns")
						end
					elseif v.components.combat:CanBeAttacked() then
						-- NOTES(JBK): inst.owner is nil here so this is for non worn things like the bramble trap.
						local isally = false
						if not inst.canhitplayers then
							--non-pvp, so don't hit any player followers (unless they are targeting a player!)
							local leader = v.components.follower ~= nil and v.components.follower:GetLeader() or nil
							isally = leader ~= nil and leader:HasTag("player") and
								not (v.components.combat ~= nil and
									v.components.combat.target ~= nil and
									v.components.combat.target:HasTag("player"))
						end
						if not isally then
							debuff.ignore[v] = true
							v.components.combat:GetAttacked(inst, damage, nil, nil, inst.spdmg)
							local retaliation = SpawnPrefab("abigail_retaliation")
							retaliation:SetRetaliationTarget(v)
							--v:PushEvent("thorns")
						end
					end
				end
			end
		end
	end
	debuff.components.debuff:Stop()
end

-- 移除玩家鬼魂作祟加速
local SPEED_HAUNT_MULTIPLIER_NAME = "haunted_speedpot"
local function speed_potion_haunt_remove_buff(inst)
    if inst._haunted_speedpot_task ~= nil then
        inst._haunted_speedpot_task:Cancel()
        inst._haunted_speedpot_task = nil
    end
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, SPEED_HAUNT_MULTIPLIER_NAME)
	inst:RemoveEventCallback("ms_respawnedfromghost", speed_potion_haunt_remove_buff)
end

-- 玩家鬼魂作祟加速
local function speed_potion_haunt(inst, haunter)
    Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    if haunter:HasTag("playerghost") then
        haunter.components.locomotor:SetExternalSpeedMultiplier(haunter, SPEED_HAUNT_MULTIPLIER_NAME, TUNING.GHOSTLYELIXIR_SPEED_LOCO_MULT)
        if haunter._haunted_speedpot_task ~= nil then
            haunter._haunted_speedpot_task:Cancel()
            haunter._haunted_speedpot_task = nil
        end
		haunter:ListenForEvent("ms_respawnedfromghost", speed_potion_haunt_remove_buff)
        haunter._haunted_speedpot_task = haunter:DoTaskInTime(TUNING.GHOSTLYELIXIR_SPEED_PLAYER_GHOST_DURATION, speed_potion_haunt_remove_buff)
    end
    return true
end

-- 创建药剂实体
local function potion_fn(anim, potion_tunings, buff_prefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ghostly_elixirs")
    inst.AnimState:SetBuild("ghostly_elixirs")
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim
    inst.scrapbook_specialinfo = "GHOSTLYELIXER".. string.upper(anim)
    inst.elixir_buff_type = anim  -- 根据药剂buff的类型添加动画

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

	-- 小彩蛋，作祟药剂加速
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
        if target:HasTag("player") then
		    inst.potion_tunings.TICK_FN_PLAYER(inst, target)
        else
            inst.potion_tunings.TICK_FN(inst, target)
        end
    else
        inst.components.debuff:Stop()
    end
end

-- buff触发特效
local function buff_DripFx(inst, target)
    local prefab = inst.potion_tunings.dripfx
	if target:HasTag("player") then
		prefab = inst.potion_tunings.dripfx_player
	end

    if not target.inlimbo and not target.sg:HasStateTag("busy") then
		SpawnPrefab(inst.potion_tunings.dripfx).Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

-- buff持续生效(包括特效)
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
    inst.driptask = inst:DoPeriodicTask(TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY, buff_DripFx, TUNING.GHOSTLYELIXIR_DRIP_FX_DELAY * 0.25, target)

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

-- 计时器为decay时停止buff，data可能为计时器
local function buff_OnTimerDone(inst, data)
    if data.name == "decay" then
        inst.components.debuff:Stop()
    end
end

-- 药剂效果时间重置，inst应该为计时器
local function buff_OnExtended(inst, target)
    local duration = inst.potion_tunings.DURATION
	if target:HasTag("player") then
		duration = inst.potion_tunings.DURATION_PLAYER
	end

	-- 检查是否有计时器
    if (inst.components.timer:GetTimeLeft("decay") or 0) < duration then
        inst.components.timer:StopTimer("decay")  -- 停止计时器
        inst.components.timer:StartTimer("decay", duration)  -- 开一个新的计时器，即重置药剂持续时间
    end

	-- 如果已经有buff任务了，则先取消，然后再添加一个新的buff任务
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
	end

	-- 检查是否配置了特效fx，并确保目标实体不处于隐身状态inlimbo
	if inst.potion_tunings.fx ~= nil and not target.inlimbo then
		local fx = SpawnPrefab(inst.potion_tunings.fx)  -- 创建一个特效实体
	    fx.entity:SetParent(target.entity)  -- 将特效实体绑定到目标实体上
	end
end

-- 药剂效果移除
local function buff_OnDetached(inst, target)
	-- 取消周期性任务
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end

	-- 取消特效任务
	if inst.driptask ~= nil then
		inst.driptask:Cancel()
		inst.driptask = nil
	end

	-- 执行自定义药剂效果移除函数
	if target:HasTag("player") then
		if inst.potion_tunings.ONDETACH_PLAYER ~= nil then
			inst.potion_tunings.ONDETACH_PLAYER(inst, target)
		end
	else
		if inst.potion_tunings.ONDETACH ~= nil then
			inst.potion_tunings.ONDETACH(inst, target)
		end
	end
	inst:Remove()  -- 移除buff实体
end

-- 技能树增加药剂持续时间
local function buff_skill_modifier_fn(inst,doer,target)
	local duration_mult = 1

	if inst.potion_tunings.skill_modifier_long_duration and doer.components.skilltreeupdater:IsActivated("wendy_potion_duration") then
		duration_mult = duration_mult + TUNING.MYWD.POTION_DURATION_MOD  -- 自定义倍率
	end

	local duration = inst.potion_tunings.DURATION
	if target:HasTag("player") then
		duration = inst.potion_tunings.DURATION_PLAYER
	end

    inst.components.timer:StopTimer("decay")
    inst.components.timer:StartTimer("decay", duration * duration_mult )
end

-- 创建buff实体
local function buff_fn(tunings, dodelta_fn)
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)  -- 即刻移除客户端的buff实体
        return inst
    end

    inst.buff_skill_modifier_fn = buff_skill_modifier_fn
    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()  -- 隐藏实体，使其在游戏中不可见
    inst.persists = false  -- 实体在游戏保存时不会持久化

	inst.potion_tunings = tunings  -- 将传入的tunings表存储到实体的potion_tunings属性中，用于后续逻辑

    inst:AddTag("CLASSIFIED")  -- 添加标签"CLASSIFIED"，表示该实体是内部逻辑使用的辅助实体，不参与网络同步

    inst:AddComponent("debuff")  -- 添加debuff组件，用于管理buff的生命周期和逻辑
    inst.components.debuff:SetAttachedFn(buff_OnAttached)  -- 绑定回调函数，当buff被附加到目标实体时触发
    inst.components.debuff:SetDetachedFn(buff_OnDetached)  -- 绑定回调函数，当buff从目标实体移除时触发
    inst.components.debuff:SetExtendedFn(buff_OnExtended)  -- 绑定回调函数，当buff被延长时触发
    inst.components.debuff.keepondespawn = true  -- 表示目标实体离开游戏时，buff不会自动清除

    inst:AddComponent("timer")  -- timer组件，用于控制buff的持续时间
    inst.components.timer:StartTimer("decay", tunings.DURATION)  -- 启动一个名为"decay"的计时器，时间为tunings.DURATION
    inst:ListenForEvent("timerdone", buff_OnTimerDone)  -- 监听"timerdone"事件，绑定回调函数buff_OnTimerDone，处理计时器完成时的逻辑，通常是移除buff

    return inst
end

-- 添加药剂的prefab对象和buff的prefab对象
local function AddPotion(potions, name, anim)
	local potion_prefab = "ghostlyelixir_"..name
	local buff_prefab = potion_prefab.."_buff"

	local assets = 	{
		Asset("ANIM", "anim/ghostly_elixirs.zip"),
		Asset("ANIM", "anim/abigail_buff_drip.zip"),
        Asset("ANIM", "anim/player_elixir_buff_drip.zip"),
		Asset("ANIM", "anim/player_vial_fx.zip"),
	}

    if extra_assets then ConcatArrays(assets, extra_assets) end
	-- 依赖表
	local prefabs = {
		buff_prefab,  -- buff预制件
		potion_tunings[potion_prefab].fx,  -- 药剂持续特效
		potion_tunings[potion_prefab].dripfx,  -- 药剂施加特效
        potion_tunings[potion_prefab].fx_player,  -- 玩家药剂持续特效
		potion_tunings[potion_prefab].dripfx_player,    -- 玩家药剂施加特效
		"ghostvision_buff",  -- 夜视buff
	}
	-- 如果potion_tunings中定义了shield_prefab，则添加到依赖表中
	if potion_tunings[potion_prefab].shield_prefab ~= nil then
		table.insert(prefabs, potion_tunings[potion_prefab].shield_prefab)
	end

	local function _buff_fn() return buff_fn(potion_tunings[potion_prefab]) end  -- 创建buff实体，传入一个药剂配置表
	local function _potion_fn() return potion_fn(anim, potion_tunings[potion_prefab], buff_prefab) end  -- 创建药剂实体，传入动画、一个药剂配置表、buff预制体

	-- Prefab(name, fn, assets, prefabs)，name用于标识prefab对象，fn为构造函数，assets为prefab对象所需的资源列表，prefabs为依赖表，返回一个prefab对象
	table.insert(potions, Prefab(potion_prefab, _potion_fn, assets, prefabs))
	table.insert(potions, Prefab(buff_prefab, _buff_fn))
end

local potions = {}  -- 表中为药剂的prefab对象和buff的prefab对象
-- 药剂表、药剂的标识、药剂的动画(#动画只在创建药剂实体时使用)
AddPotion(potions, "slowregen", "regeneration")  -- 缓慢恢复生命值
AddPotion(potions, "fastregen", "healing")  -- 快速恢复生命值
AddPotion(potions, "attack", "attack")  -- 增强攻击力
AddPotion(potions, "speed", "speed")  -- 提升移动速度
AddPotion(potions, "shield", "shield")  -- 提供护盾保护
AddPotion(potions, "retaliation", "retaliation")  -- 反伤
AddPotion(potions, "revive", "revive")  -- 回忆灵药
AddPotion(potions, "lunar", "lunar")  -- 月亮药剂
AddPotion(potions, "shadow", "shadow")  -- 暗影药剂

return unpack(potions)