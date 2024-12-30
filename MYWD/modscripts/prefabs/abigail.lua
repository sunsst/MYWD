local assets =
{
    Asset("ANIM", "anim/player_ghost_withhat.zip"),
    Asset("ANIM", "anim/ghost_abigail_build.zip"),

    Asset("ANIM", "anim/ghost_abigail.zip"),
    Asset("ANIM", "anim/ghost_abigail_gestalt.zip"),

    Asset("ANIM", "anim/lunarthrall_plant_front.zip"),
    Asset("ANIM", "anim/brightmare_gestalt_evolved.zip"),
    Asset("ANIM", "anim/ghost_abigail_commands.zip"),
    Asset("ANIM", "anim/ghost_abigail_gestalt_build.zip"),
    Asset("ANIM", "anim/ghost_abigail_shadow_build.zip"),

    Asset("SOUND", "sound/ghost.fsb"),
}

local prefabs =
{
    "abigail_attack_fx",
    "abigail_attack_fx_ground",
	"abigail_retaliation",
	"abigailforcefield",
	"abigaillevelupfx",
	"abigail_vex_debuff",
    "abigail_vex_shadow_debuff",
    "abigail_attack_shadow_fx",
    "abigail_gestalt_hit_fx",
    "abigail_rising_twinkles_fx",
    "abigail_shadow_buff_fx",
}

local brain = require("brains/abigailbrain")

-- 设置血量上限
local function SetMaxHealth(inst)
    local health = inst.components.health
    if health then
        if health:IsDead() then
            health.maxhealth = inst.base_max_health + inst.bonus_max_health  -- 最大血量为基本血量 + 额外血量
        else
            local health_percent = health:GetPercent()
            health:SetMaxHealth( inst.base_max_health + inst.bonus_max_health )
            health:SetPercent(health_percent, true)
        end

        -- 在温蒂身上更新阿比盖尔的血量上限，inst._playerlink为关联的玩家，pethealthbar为随从健康条
        if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
            inst._playerlink.components.pethealthbar:SetMaxHealth(health.maxhealth)
        end
    end
end

-- 根据等级更新阿比盖尔的光照等级
local function UpdateGhostlyBondLevel(inst, level)
    -- 阿比盖尔血量等级
	local max_health = level == 3 and TUNING.ABIGAIL_HEALTH_LEVEL3
					or level == 2 and TUNING.ABIGAIL_HEALTH_LEVEL2
					or TUNING.ABIGAIL_HEALTH_LEVEL1

    inst.base_max_health = max_health
    SetMaxHealth(inst)  -- 更新上限

    -- 更新温蒂的链接状态
	local light_vals = TUNING.ABIGAIL_LIGHTING[level] or TUNING.ABIGAIL_LIGHTING[1]
	if light_vals.r ~= 0 then
		inst.Light:Enable(not inst.inlimbo)  -- inlimbo临时消失状态
		inst.Light:SetRadius(light_vals.r)  -- 光照半径
		inst.Light:SetIntensity(light_vals.i)  -- 光照强度
		inst.Light:SetFalloff(light_vals.f)  -- 光照衰减
	else
		inst.Light:Enable(false)
	end
    inst.AnimState:SetLightOverride(light_vals.l)  -- 设置角色动画状态的光照覆盖层次
end

local ABIGAIL_DEFENSIVE_MAX_FOLLOW_DSQ = TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW * TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW  -- Abigail防御模式下的跟随范围
local ABIGAIL_GESTALT_DEFENSIVE_MAX_FOLLOW_DSQ = TUNING.ABIGAIL_GESTALT_DEFENSIVE_MAX_FOLLOW * TUNING.ABIGAIL_GESTALT_DEFENSIVE_MAX_FOLLOW  -- (某种形态)Abigail防御模式下的跟随范围

-- 判断阿比盖尔和温蒂的距离是否小于阿比盖尔的防御距离(有两种防御距离)
local function IsWithinDefensiveRange(inst)
    local range = ABIGAIL_DEFENSIVE_MAX_FOLLOW_DSQ
    if inst:HasTag("gestalt") and inst.components.combat.target then
        range = ABIGAIL_GESTALT_DEFENSIVE_MAX_FOLLOW_DSQ
    end
    -- inst:GetDistanceSqToInst(inst._playerlink)获取温蒂和阿比盖尔之间的距离
    return (inst._playerlink ~= nil) and inst:GetDistanceSqToInst(inst._playerlink) < range
end

-- 用于设置实体的物理碰撞属性，on：bool值，控制是否启用透明碰撞模式
local function SetTransparentPhysics(inst, on)
    inst.Physics:ClearCollisionMask()  -- 清除实体当前的所有碰撞类型
    -- CollidesWith 是一个方法，用于添加特定的碰撞类型，CanFlyingCrossBarriers()飞跃障碍，COLLISION.GROUND与地面碰撞，COLLISION.WORLD与世界边界碰撞
    inst.Physics:CollidesWith((TheWorld:CanFlyingCrossBarriers() and COLLISION.GROUND) or COLLISION.WORLD)
    if not on then
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)  -- 允许与角色发生碰撞
        inst.Physics:CollidesWith(COLLISION.GIANTS)  -- 允许与巨型生物发生碰撞
    end
end

local COMBAT_MUSHAVE_TAGS = { "_combat", "_health" }  -- 给阿比盖尔添加标签，"_combat"表示具有战斗能力，"_health"表示可以受到伤害
local COMBAT_CANTHAVE_TAGS = { "INLIMBO", "noauradamage", "companion" }  -- 给阿比盖尔添加标签，"INLIMBO" 表示对象处于消失状态，通常无法与之交战，"noauradamage"表示对象不能受到光环类伤害，"companion"表示对象是玩家的同伴，不应作为攻击目标

local COMBAT_MUSTONEOF_TAGS_AGGRESSIVE = { "monster", "prey", "insect", "hostile", "character", "animal" }  -- 在攻击模式下允许攻击的目标，"monster"怪物，"prey"猎物，"insect"昆虫，"hostile"敌对生物，"character"角色，"animal"动物
local COMBAT_MUSTONEOF_TAGS_DEFENSIVE = { "monster", "prey" }  -- 在防御模式下允许攻击的目标，"monster"怪物，"prey"猎物

local COMBAT_TARGET_DSQ = TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE * TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE  -- 阿比盖尔攻击目标感知范围

-- 判断阿比盖尔是否对目标友好
local function HasFriendlyLeader(inst, target, PVP_enabled)
    local leader = (inst.components.follower ~= nil and inst.components.follower.leader) or nil  -- 获取温蒂
    if not leader then
        return false
    end

    local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil  -- 获取目标的leader

    if target_leader and target_leader.components.inventoryitem then
        target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        -- Don't attack followers if their follow object has no owner
        if not target_leader then
            return true
        end
    end

    if PVP_enabled == nil then
        PVP_enabled = TheNet:GetPVPEnabled()  -- PVP模式
    end

    -- 判断友好条件
    return leader == target
        or (
            target_leader ~= nil  -- 如果目标是温蒂
            and (
                target_leader == leader or (not PVP_enabled and target_leader.isplayer)  -- 如果目标的领导是温蒂或者玩家
            )
        ) or (
            not PVP_enabled  -- 如果没有开启PVP模式
            and target.components.domesticatable ~= nil
            and target.components.domesticatable:IsDomesticated()  -- 如果目标是驯化的动物
        ) or (
            not PVP_enabled
            and target.components.saltlicker ~= nil
            and target.components.saltlicker.salted  -- 如果目标受盐块效果影响
        )
end

-- 判断对方是否可以成为阿比盖尔的目标
local function CommonRetarget(inst, v)
    return v ~= inst and v ~= inst._playerlink and v.entity:IsVisible()  -- 目标不是自己，目标不是温蒂，目标不是不可见
            and v:GetDistanceSqToInst(inst._playerlink) < COMBAT_TARGET_DSQ  -- 位于温蒂的攻击范围内
            and inst.components.combat:CanTarget(v)  -- 可以攻击对方
            and v.components.minigame_participator == nil  -- 对方不是小游戏参与者
            and not HasFriendlyLeader(inst, v)  -- 对方不是友好目标
            and not inst.components.timer:TimerExists("block_retargets")  -- 检查是否存在阻止重新选择目标的计时器
end

-- 判断阿比盖尔是否需要进入防御模式，进入防御模式之后选择攻击目标
local function DefensiveRetarget(inst)
    if not inst._playerlink or not IsWithinDefensiveRange(inst) then  -- 如果温蒂不存在，或者不在防御范围内
        return nil
    else
        local ix, iy, iz = inst.Transform:GetWorldPosition()  -- 获取阿比盖尔的坐标
        local entities_near_me = TheSim:FindEntities(  -- 获取包含所有目标的表
            ix, iy, iz, TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW,  -- 在指定范围内查找目标
            COMBAT_MUSHAVE_TAGS, COMBAT_CANTHAVE_TAGS, COMBAT_MUSTONEOF_TAGS_DEFENSIVE  -- 包含指定标签
        )

        for _, v in ipairs(entities_near_me) do  -- 遍历目标表
            if CommonRetarget(inst, v)  -- 如果可以成为目标
                    and (v.components.combat.target == inst._playerlink or  -- 目标正在攻击温蒂
                        inst._playerlink.components.combat.target == v or  -- 温蒂正在攻击目标
                        v.components.combat.target == inst) then  -- 目标正在攻击阿比盖尔

                return v  -- 选择第一个对象来反击
            end
        end

        return nil
    end
end

-- 在攻击模式中，选择攻击目标
local function AggressiveRetarget(inst)
    if inst._playerlink == nil then  -- 如果温蒂不存在
        return nil
    end
    local ix, iy, iz = inst.Transform:GetWorldPosition()  -- 获取阿比盖尔的坐标
    local entities_near_me = TheSim:FindEntities(  -- 获取包含所有目标的表
        ix, iy, iz, TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE,  -- 在指定范围内查找目标
        COMBAT_MUSHAVE_TAGS, COMBAT_CANTHAVE_TAGS, COMBAT_MUSTONEOF_TAGS_AGGRESSIVE  -- 包含指定标签
    )

    for _, entity_near_me in ipairs(entities_near_me) do
        if CommonRetarget(inst, entity_near_me) then  -- 如果对方可以成为目标
            return entity_near_me
        end
    end

    return nil
end

-- 启动阿比盖尔的强力护盾
local function StartForceField(inst)
    -- 如果阿比盖尔不处于dissipate状态(消失状态)，且没有护盾，还没有死亡
	if not inst.sg:HasStateTag("dissipate") and not inst:HasDebuff("forcefield") and (inst.components.health == nil or not inst.components.health:IsDead()) then
		local elixir_buff = inst:GetDebuff("abigail_shield_buff")  -- 获取药剂buff标签，已修改，原来是"elixir_buff"
        -- 添加buff，如果存在药剂buff，则从药剂表中获取shield_prefab预制件，否则生效默认护盾abigailforcefield
		inst:AddDebuff("forcefield", elixir_buff ~= nil and elixir_buff.potion_tunings.shield_prefab or "abigailforcefield")  -- 添加buff也是添加护盾
	end
end

-- 阿比盖尔的攻击逻辑和反伤逻辑，data为伤害数据
local function OnAttacked(inst, data)
    local combat = inst.components.combat
    if data.attacker == nil then  -- 攻击者不存在，表示环境伤害
        combat:SetTarget(nil)
    elseif not data.attacker:HasTag("noauradamage") then  -- 伤害的攻击者不存在noauradamage标签
        -- 如果我们正在阻挡目标，而我们的目标仍然有效，不要自动切换
        local is_blocking_retargets = inst.components.timer:TimerExists("block_retargets")
        if not is_blocking_retargets or not combat:IsValidTarget(combat.target) then
            if not inst.is_defensive then  -- 处于攻击模式
                combat:SetTarget(data.attacker)  -- 反击
            -- 阿比盖尔处于温蒂的防御范围内，目标到温蒂的距离小于阿比盖尔的防御范围内
            elseif inst:IsWithinDefensiveRange() and inst._playerlink:GetDistanceSqToInst(data.attacker) < ABIGAIL_DEFENSIVE_MAX_FOLLOW_DSQ then
                -- Basically, we avoid targetting the attacker if they're far enough away that we wouldn't reach them anyway.
                combat:SetTarget(data.attacker)
            end
        end
    end

    -- 用于反伤
	if inst:HasDebuff("forcefield") then  -- 有护盾buff
        -- 存在伤害的攻击者，伤害的攻击者不是温蒂，伤害的攻击者有攻击组件
		if data.attacker ~= nil and data.attacker ~= inst._playerlink and data.attacker.components.combat ~= nil then
			if inst:GetDebuff("abigail_retaliation_buff") ~= nil then  -- 如果有蒸馏复仇buff
				local retaliation = SpawnPrefab("abigail_retaliation")  -- 生成阿比盖尔反击预制件GetDistanceSqToPoint
				retaliation:SetRetaliationTarget(data.attacker)  -- 设置反伤目标
			end
            inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/shield/on")  -- 护盾声音
		end
    end

    StartForceField(inst)  -- 启动护盾
end

-- 温蒂攻击阿比盖尔收回阿比盖尔
local function OnBlocked(inst, data)
    if data ~= nil and inst._playerlink ~= nil and data.attacker == inst._playerlink then
		if inst.components.health ~= nil and not inst.components.health:IsDead() then
			inst._playerlink.components.ghostlybond:Recall()
		end
	end
end

-- 阿比盖尔死亡
local function OnDeath(inst)
    inst.components.aura:Enable(false)  -- 禁用易伤buff
	inst:RemoveDebuff("ghostlyelixir")  -- 移除药剂buff
	inst:RemoveDebuff("forcefield")  -- 移除护盾buff
end

-- 阿比盖尔安抚
local function OnRemoved(inst)
    inst:BecomeDefensive()
end

-- 给目标添加易伤buff
local function auratest(inst, target)
    if target == inst._playerlink then
        return false
    end

	if target.components.minigame_participator ~= nil then
		return false
	end

    if (target:HasTag("player") and not TheNet:GetPVPEnabled()) or target:HasTag("ghost") or target:HasTag("noauradamage") then
        return false
    end

    -- 如果目标是温蒂或者温蒂的随从
    local leader = inst.components.follower.leader
    if leader ~= nil
        and (leader == target
            or (target.components.follower ~= nil and
                target.components.follower.leader == leader)) then
        return false
    end

    -- 如果阿比盖尔没有激怒，且不在温蒂的防御范围内，can_initiate可以初始化
    if inst.is_defensive and not can_initiate and not IsWithinDefensiveRange(inst) then
        return false
    end

    -- 如果是阿比盖尔的攻击目标
    if inst.components.combat.target == target then
        return true
    end

    -- 如果目标的攻击目标是温蒂或者阿比盖尔
    if target.components.combat.target ~= nil
        and (target.components.combat.target == inst or
            target.components.combat.target == leader) then
        return true
    end

    -- 如果目标是怪物，但目标是玩家的随从，或者目标拥有bedazzled
    local ismonster = target:HasTag("monster")
    if ismonster and not TheNet:GetPVPEnabled() and 
       ((target.components.follower and target.components.follower.leader ~= nil and 
         target.components.follower.leader:HasTag("player")) or target.bedazzled) then
        return false
    end

    
    -- 如果目标拥有companion同伴标签，如果目标是怪物或者拥有猎物标签，如果目标可以初始化
    return not target:HasTag("companion") and
        (can_initiate or ismonster or target:HasTag("prey"))
end

-- 更新阿比盖尔的伤害
local function UpdateDamage(inst)
    -- 如果使用了药剂，则获得abigail_attack_buff，则将阶段设置为夜晚，否则使用当前世界阶段
	local phase = inst:GetDebuff("abigail_attack_buff") ~= nil and "night" or TheWorld.state.phase
	inst.components.combat.defaultdamage = (TUNING.ABIGAIL_DAMAGE[phase] or TUNING.ABIGAIL_DAMAGE.day) / TUNING.ABIGAIL_VEX_DAMAGE_MOD -- so abigail does her intended damage defined in tunings.lua
    -- 计算阿比盖尔造成的伤害，如果没有阶段伤害，则使用白天的伤害，TUNING.ABIGAIL_VEX_DAMAGE_MOD用于调整阿比盖尔的伤害

    -- 根据阶段确定攻击等级
    inst.attack_level = phase == "day" and 1
						or phase == "dusk" and 2
						or 3

    -- 根据攻击等级来选择不同的动画效果
    -- If the animation fx was already playing we update its animation
    local level_str = tostring(inst.attack_level)
    if inst.attack_fx and not inst.attack_fx.AnimState:IsCurrentAnimation("attack" .. level_str .. "_loop") then
        inst.attack_fx.AnimState:PlayAnimation("attack" .. level_str .. "_loop", true)
    end

    if inst.attack_fx_ground and not inst.attack_fx_ground.AnimState:IsCurrentAnimation("attack" .. level_str .. "_ground_loop") then
        inst.attack_fx_ground.AnimState:PlayAnimation("attack" .. level_str .. "_ground_loop", true)
    end
end

-- 阿比盖尔血量检查，当阿比盖尔血量过低时，进行检查
local function AbigailHealthDelta(inst, data)
	if not inst._playerlink then return end
	if data.oldpercent > data.newpercent and data.newpercent <= 0.25 and not inst.issued_health_warning then
		inst._playerlink.components.talker:Say(GetString(inst._playerlink, "ANNOUNCE_ABIGAIL_LOW_HEALTH"))
		inst.issued_health_warning = true  -- 设置标志，只在第一次下降时触发
	elseif data.oldpercent < data.newpercent and data.newpercent > 0.33 then
		inst.issued_health_warning = false  -- 设置标志，恢复血量到一定程度可以继续触发警告
	end
end

-- 阿比盖尔召唤
local function DoAppear(sg)
	sg:GoToState("appear")
end

-- 控制阿比盖尔是否可以接收某个物品，全都无法接受，如果物品是reviver，则返回一个错误信息
local function AbleToAcceptTest(inst, item)
    return false, (item.prefab == "reviver" and "ABIGAILHEART") or nil
end

-- 添加药剂buff，name为药剂名，debuff为buff实体，用于添加药剂buff在血量值上的图标
local function OnDebuffAdded(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "super_elixir_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol2(debuff.prefab)
        elseif name ~= nil then  -- 或者name == "elixir_buff"，只需要控制传入的buff名称即可
            inst._playerlink.components.pethealthbar:SetSymbol(debuff.prefab)
        end
    end
end

-- 移除药剂buff在血量值上的图标
local function OnDebuffRemoved(inst, name, debuff)
    if inst._playerlink ~= nil and inst._playerlink.components.pethealthbar ~= nil then
        if name == "super_elixir_buff" then
            inst._playerlink.components.pethealthbar:SetSymbol2(0)
        elseif name ~= nil then  -- 或者name == "elixir_buff"，只需要控制传入的buff名称即可
            inst._playerlink.components.pethealthbar:SetSymbol(0)
        end
	end
end

-- 当阿比盖尔没有执行某个动画时，生效一个升级动画
local function on_ghostlybond_level_change(inst, player, data)
	if not inst.inlimbo and data.level > 1 and not inst.sg:HasStateTag("busy") and (inst.components.health == nil or not inst.components.health:IsDead()) then
		inst.sg:GoToState("ghostlybond_levelup", {level = data.level})
	end
	UpdateGhostlyBondLevel(inst, data.level)
end

-- 阿比盖尔激怒
local function BecomeAggressive(inst)
    inst.AnimState:OverrideSymbol("ghost_eyes", "ghost_abigail_build", "angry_ghost_eyes")
    inst.is_defensive = false
    inst._playerlink:AddTag("has_aggressive_follower")
    inst.components.combat:SetRetargetFunction(0.5, AggressiveRetarget)  -- 0.5s后执行攻击逻辑
end

-- 阿比盖尔安抚
local function BecomeDefensive(inst)
    inst.AnimState:ClearOverrideSymbol("ghost_eyes")
    inst.is_defensive = true
	if inst._playerlink ~= nil then
	    inst._playerlink:RemoveTag("has_aggressive_follower")
	end
    inst.components.combat:SetRetargetFunction(0.5, DefensiveRetarget)  -- 0.5s后执行防御逻辑
end

-- 失去玩家链接
local function onlostplayerlink(inst)
	inst._playerlink = nil
end

-- 为目标添加一个abigail_vex_debuff的debuff(易伤buff)，并根据情况为debuff添加外观和皮肤
local function ApplyDebuff(inst, data)
	local target = data ~= nil and data.target
	if target ~= nil then
        target:AddDebuff("abigail_vex_debuff", "abigail_vex_debuff")

        local debuff = target:GetDebuff("abigail_vex_debuff")
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil and debuff ~= nil then
            debuff.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", inst.GUID, "abigail_attack_fx" )  -- 覆盖debuff动画符号
        end
	end
end

local function ApplyDebuff(inst, data)
	local target = data ~= nil and data.target
	if target ~= nil then
        local buff = "abigail_vex_debuff"

        if inst:GetDebuff("super_elixir_buff") and inst:GetDebuff("super_elixir_buff").prefab == "ghostlyelixir_shadow_buff" then
            buff = "abigail_vex_shadow_debuff"
        end

        local olddebuff = target:GetDebuff("abigail_vex_debuff")
        if olddebuff and olddebuff.prefab ~= buff then
            target:RemoveDebuff("abigail_vex_debuff")
        end

        target:AddDebuff("abigail_vex_debuff", buff, nil, nil, nil, inst)

        local debuff = target:GetDebuff("abigail_vex_debuff")
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil and debuff ~= nil then
            debuff.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", inst.GUID, "abigail_attack_fx" )
        end
	end
end

-- 链接温蒂和阿比盖尔
local function linktoplayer(inst, player)
    inst.persists = false  -- 实体被移除后不会保持在游戏中
    inst._playerlink = player

    BecomeDefensive(inst)  -- 默认防御模式

    inst:ListenForEvent("healthdelta", AbigailHealthDelta)  -- 监听事件
    inst:ListenForEvent("onareaattackother", ApplyDebuff)  -- 在实体进行区域攻击时对敌人添加一个debuff

    player.components.leader:AddFollower(inst)
    if player.components.pethealthbar ~= nil then
        player.components.pethealthbar:SetPet(inst, "", TUNING.ABIGAIL_HEALTH_LEVEL1)  -- 设置阿比盖尔随从血量值

        local elixir_buff = inst:GetDebuff("elixir_buff")
        if elixir_buff then
            player.components.pethealthbar:SetSymbol(elixir_buff.prefab)  -- 设置buff增益符号
        end
        local elixir_buff2 = inst:GetDebuff("super_elixir_buff")
        if elixir_buff2 then
            player.components.pethealthbar:SetSymbol2(elixir_buff2.prefab)
        end
    end

    if player:HasTag("player_shadow_aligned") then
        inst:AddTag("shadow_aligned")
        local damagetyperesist = inst.components.damagetyperesist
        if damagetyperesist then
             damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WENDY.ALLEGIANCE_SHADOW_RESIST, "allegiance_shadow")
        end
        local damagetypebonus = inst.components.damagetypebonus
        if damagetypebonus then
            damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WENDY.ALLEGIANCE_VS_LUNAR_BONUS, "allegiance_shadow")
        end
        inst.components.planardefense:SetBaseDefense(TUNING.SKILLS.WENDY.GHOST_PLANARDEFENSE)
    end

    if player:HasTag("player_lunar_aligned") then        
        inst:AddTag("lunar_aligned")
        local damagetyperesist = inst.components.damagetyperesist
        if damagetyperesist then
             damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WENDY.ALLEGIANCE_LUNAR_RESIST, "allegiance_lunar")
        end
        local damagetypebonus = inst.components.damagetypebonus
        if damagetypebonus then
            damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WENDY.ALLEGIANCE_VS_SHADOW_BONUS, "allegiance_lunar")
        end
        inst.components.planardefense:SetBaseDefense(TUNING.SKILLS.WENDY.GHOST_PLANARDEFENSE)
    end

    UpdateGhostlyBondLevel(inst, player.components.ghostlybond.bondlevel)
    inst:ListenForEvent("ghostlybond_level_change", inst._on_ghostlybond_level_change, player)  -- 监听是否升级
    inst:ListenForEvent("onremove", inst._onlostplayerlink, player)  --监听是否失去温蒂
end

-- 设置召唤出阿比盖尔之后，光照的等级
local function OnExitLimbo(inst)
	local level = (inst._playerlink ~= nil and inst._playerlink.components.ghostlybond ~= nil) and inst._playerlink.components.ghostlybond.bondlevel or 1
	local light_vals = TUNING.ABIGAIL_LIGHTING[level] or TUNING.ABIGAIL_LIGHTING[1]
	inst.Light:Enable(light_vals.r ~= 0)
end

-- 函数根据阿比盖尔与玩家的绑定关系，返回当前绑定级别的状态
local function getstatus(inst)
	local bondlevel = (inst._playerlink ~= nil and inst._playerlink.components.ghostlybond ~= nil) and inst._playerlink.components.ghostlybond.bondlevel or 0
	return bondlevel == 3 and "LEVEL3"
		or bondlevel == 2 and "LEVEL2"
		or "LEVEL1"
end

-- 创建阿比盖尔
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("ghost")
    inst.AnimState:SetBuild("ghost_abigail_build")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    inst.AnimState:AddOverrideBuild("ghost_abigail_gestalt")  -- 月灵阿比的动画

    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("girl")
    inst:AddTag("ghost")
    inst:AddTag("flying")
    inst:AddTag("noauradamage")
    inst:AddTag("notraptrigger")
    inst:AddTag("abigail")
    inst:AddTag("NOBLOCK")

    inst:AddTag("trader") --trader (from trader component) added to pristine state for optimization
	inst:AddTag("ghostlyelixirable") -- for ghostlyelixirable component

    MakeGhostPhysics(inst, 1, .5)

    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.6)
    inst.Light:Enable(false)
    inst.Light:SetColour(180 / 255, 195 / 255, 225 / 255)

    inst.point_filtered = net_bool(inst.GUID, "abigail.point_filtered", "point_filtereddirty")
    inst.point_filtered:set(false)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("point_filtereddirty", OnPointFilterDirty)
    end

    --It's a loop that's always on, so we can start this in our pristine state
    -- inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl_LP", "howl")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_damage = { TUNING.ABIGAIL_DAMAGE.day, TUNING.ABIGAIL_DAMAGE.night }
    inst.scrapbook_ignoreplayerdamagemod = true

    inst.is_defensive = true
    inst.issued_health_warning = false
    -- inst._playerlink = nil

    -- 作祟目标
    inst._OnHauntTargetRemoved = function()
        if inst._haunt_target then
            inst:RemoveEventCallback("onremove", inst._OnHauntTargetRemoved, inst._haunt_target)
            inst._haunt_target = nil
        end
    end

    inst:SetBrain(brain)
    inst:SetStateGraph("SGabigail")
    inst.sg.OnStart = DoAppear

    inst:AddComponent("fader")

    -- 控制阿比盖尔的移速和行为
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.ABIGAIL_SPEED*.5
    inst.components.locomotor.runspeed = TUNING.ABIGAIL_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }
    inst.components.locomotor:SetTriggersCreep(false)

    inst:SetStateGraph("SGabigail")
	inst.sg.OnStart = DoAppear

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("debuffable")
	inst.components.debuffable.ondebuffadded = OnDebuffAdded
	inst.components.debuffable.ondebuffremoved = OnDebuffRemoved

    inst.base_max_health = TUNING.ABIGAIL_HEALTH_LEVEL1
    inst.bonus_max_health = 0

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ABIGAIL_HEALTH_LEVEL1)
    inst.components.health:StartRegen(1, 1)
	inst.components.health.nofadeout = true
	inst.components.health.save_maxhealth = true

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = TUNING.ABIGAIL_DMG_PLAYER_PERCENT
	inst.components.combat:SetKeepTargetFunction(auratest)
    inst.components.combat.customdamagemultfn = CustomCombatDamage

    inst:AddComponent("aura")
    inst.components.aura.radius = 4
    inst.components.aura.tickperiod = 1
    inst.components.aura.ignoreallies = true
    inst.components.aura.auratestfn = auratest

    inst.auratest = auratest
    inst.BecomeDefensive = BecomeDefensive
    inst.BecomeAggressive = BecomeAggressive
    inst.IsWithinDefensiveRange = IsWithinDefensiveRange
    inst.LinkToPlayer = linktoplayer
    inst.SetTransparentPhysics = SetTransparentPhysics
    inst.ApplyDebuff = ApplyDebuff

    ------------------
    --Added so you can attempt to give hearts to trigger flavour text when the action fails
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)

	inst:AddComponent("ghostlyelixirable")
    inst:AddComponent("planardamage")
    inst:AddComponent("planardefense")
    inst:AddComponent("damagetyperesist")
    inst:AddComponent("damagetypebonus")

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

	inst:AddComponent("timer")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("blocked", OnBlocked)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("onremove", OnRemoved)
	inst:ListenForEvent("exitlimbo", OnExitLimbo)
    inst:ListenForEvent("do_ghost_escape", DoGhostEscape)
    inst:ListenForEvent("do_ghost_scare", DoGhostScare)
    inst:ListenForEvent("do_ghost_attackat", DoGhostAttackAt)
    inst:ListenForEvent("do_ghost_hauntat", DoGhostHauntAt)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("pre_health_setval", OnHealthChanged)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    inst.BecomeDefensive = BecomeDefensive
    inst.BecomeAggressive = BecomeAggressive

    inst.IsWithinDefensiveRange = IsWithinDefensiveRange

    inst.LinkToPlayer = linktoplayer

    inst:WatchWorldState("phase", UpdateDamage)
	UpdateDamage(inst, TheWorld.state.phase)
	inst.UpdateDamage = UpdateDamage
    inst.DoShadowBurstBuff = DoShadowBurstBuff
    inst.UpdateBonusHealth = UpdateBonusHealth
    inst.ChangeToGestalt = ChangeToGestalt
    inst.SetToGestalt = SetToGestalt
    inst.SetToNormal = SetToNormal
    inst.AddBonusHealth = AddBonusHealth

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	inst._on_ghostlybond_level_change = function(player, data) on_ghostlybond_level_change(inst, player, data) end
	inst._onlostplayerlink = function(player) onlostplayerlink(inst, player) end

    return inst
end

-------------------------------------------------------------------------------

-- 报复目标，跟随目标，攻击目标
local function SetRetaliationTarget(inst, target)
	inst._RetaliationTarget = target
	inst.entity:SetParent(target.entity)  -- 将阿比盖尔绑定到目标实体上，阿比盖尔的移动位置会跟随目标

    -- 根据目标的实际情况缩放阿比盖尔
	local s = (1 / target.Transform:GetScale()) * (target:HasTag("largecreature") and 1.1 or .8)
	if s ~= 1 and s ~= 0 then
		inst.Transform:SetScale(s, s, s)
	end

    -- 解除绑定
	inst.detachretaliationattack = function(t)
		if inst._RetaliationTarget ~= nil and inst._RetaliationTarget == t then
			inst.entity:SetParent(nil)
			inst.Transform:SetPosition(t.Transform:GetWorldPosition())
		end
	end

	inst:ListenForEvent("onremove", inst.detachretaliationattack, target)
	inst:ListenForEvent("death", inst.detachretaliationattack, target)
end

-- 定义了报复伤害和逻辑
local function DoRetaliationDamage(inst)
	local target = inst._RetaliationTarget
    -- 确保目标存在，且可被攻击
	if target ~= nil and target:IsValid() and not target.inlimbo and target.components.combat ~= nil then
		target.components.combat:GetAttacked(inst, TUNING.GHOSTLYELIXIR_RETALIATION_DAMAGE)  -- 对目标造成报复伤害
		inst:detachretaliationattack(target)  -- 解除绑定
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/shield/retaliation_fx")  -- 攻击音效

	end
end

-- 阿比盖尔报复攻击的视觉效果
local function retaliationattack_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("abigail_shield")
    inst.AnimState:SetBuild("abigail_shield")
    inst.AnimState:PlayAnimation("retaliation_fx")
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")
    inst.AnimState:SetLightOverride(.1)
	inst.AnimState:SetFinalOffset(3)

    --It's a loop that's always on, so we can start this in our pristine state
    -- inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl_LP", "howl")

	inst:AddTag("FX")  -- FX标签，表示这是一个特效实体

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst._RetaliationTarget = nil
	inst.SetRetaliationTarget = SetRetaliationTarget
	inst:DoTaskInTime(12*FRAMES, DoRetaliationDamage)  -- 12帧后对目标造成报复伤害
	inst:DoTaskInTime(30*FRAMES, inst.Remove)  -- 30帧后移除报复特效

	return inst
end

-------------------------------------------------------------------------------

local function CustomCombatDamage(inst, target)
    local vex_debuff = target:GetDebuff("abigail_vex_debuff")
    return (vex_debuff ~= nil and vex_debuff.prefab == "abigail_vex_debuff" and 1/TUNING.ABIGAIL_VEX_DAMAGE_MOD)
        or (vex_debuff ~= nil and vex_debuff.prefab == "abigail_vex_shadow_debuff" and 1/TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD)
        or 1
end

-- Ghost Command helpers
local function do_transparency(transparency_level, inst)
    inst.AnimState:OverrideMultColour(1.0, 1.0, 1.0, transparency_level)
end

local function DoGhostEscape(inst)
    if (inst.sg and inst.sg:HasStateTag("nocommand"))
            or (inst.components.health and inst.components.health:IsDead()) then
        return
    end

    if not inst:HasTag("gestalt_hide") then
        inst.components.fader:Fade(1.0, 0.3, 0.75, do_transparency)
        inst.components.aura:Enable(false)
    end
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "transparency", 1.25)
    inst:AddTag("notarget")
    inst._is_transparent = true

	inst.components.timer:StartTimer("undo_transparency", TUNING.WENDYSKILL_ESCAPE_TIME)
    inst.point_filtered:set(true)
    -- Pushing a nil target should cause anybody targetting Abigail to drop her.
	inst:PushEvent("transfercombattarget", nil)
    inst.components.combat:SetTarget(nil)
	inst.sg:GoToState("escape")
end

local function apply_panic_fx(target, fx_prefab)
	local fx = SpawnPrefab(fx_prefab)
	if fx then
		fx.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	return fx
end

local SCARE_RADIUS = 10
local SCARE_MUST_HAVE_TAGS = {"_combat", "_health"}
local SCARE_CANT_HAVE_TAGS = { "balloon", "butterfly", "companion", "epic", "groundspike", "INLIMBO", "smashable", "structure", "wall"}
local function DoGhostScare(inst)
    if (inst.sg and inst.sg:HasStateTag("nocommand"))
            or (inst.components.health and inst.components.health:IsDead()) then
        return
    end

    if inst:HasTag("gestalt_hide") then
        if inst._playerlink then inst._playerlink.components.talker:Say(GetString(inst._playerlink, "ANNOUNCE_ABIGAIL_HIDING")) end
        return
    end

    local PVP_enabled = TheNet:GetPVPEnabled()
    local doer = inst._playerlink

	local x, y, z = inst.Transform:GetWorldPosition()
	local targets_near_me = TheSim:FindEntities(x, y, z, SCARE_RADIUS, SCARE_MUST_HAVE_TAGS, SCARE_CANT_HAVE_TAGS)
	for _, target in ipairs(targets_near_me) do
		if inst.components.combat:CanTarget(target)
				and not HasFriendlyLeader(doer, target, PVP_enabled)
				and (not target:HasTag("prey") or target:HasTag("hostile")) then

			if target.components.hauntable and target.components.hauntable.panicable then
                target.components.hauntable:Panic(7)
				target:DoTaskInTime(0.25 * math.random(), apply_panic_fx, "battlesong_instant_panic_fx")
			end
		end
	end
end

local ATTACK_MUST_TAGS = {"_health", "_combat"}
local ATTACK_NO_TAGS = {"DECOR", "FX", "INLIMBO", "NOCLICK"}
local function DoGhostAttackAt(inst, pos)
    if (inst.sg and inst.sg:HasStateTag("nocommand"))
            or (inst.components.health and inst.components.health:IsDead()) then
        return
    end

    if inst:HasTag("gestalt_hide") then
        if inst._playerlink then inst._playerlink.components.talker:Say(GetString(inst._playerlink, "ANNOUNCE_ABIGAIL_HIDING")) end
        return
    end

    local px, py, pz = pos:Get()
    local targets_near_position = TheSim:FindEntities(px, py, pz, 2, ATTACK_MUST_TAGS, ATTACK_NO_TAGS)
    if #targets_near_position > 0 then
        inst.components.combat:SetTarget(targets_near_position[1])

        local timer = inst.components.timer
        if timer:TimerExists("block_retargets") then
            timer:SetTimeLeft("block_retargets", TUNING.WENDYSKILL_COMMAND_COOLDOWN)
        else
            timer:StartTimer("block_retargets", TUNING.WENDYSKILL_COMMAND_COOLDOWN)
        end
    else
        inst.components.combat:SetTarget(nil)
    end

    inst.components.aura:Enable(false)

	inst.sg:GoToState("abigail_attack_start", pos)
end

local HAUNT_CANT_TAGS = {"catchable", "DECOR", "FX", "haunted", "INLIMBO", "NOCLICK"}
local function DoGhostHauntAt(inst, pos)
    if (inst.sg and inst.sg:HasStateTag("nocommand"))
            or (inst.components.health and inst.components.health:IsDead()) then
        return
    end

    if inst:HasTag("gestalt_hide") then
        if inst._playerlink then inst._playerlink.components.talker:Say(GetString(inst._playerlink, "ANNOUNCE_ABIGAIL_HIDING")) end
        return
    end


	local px, py, pz = pos:Get()
	local targets_near_position = TheSim:FindEntities(px, py, pz, 2, nil, HAUNT_CANT_TAGS)
	if #targets_near_position > 0 then
        inst._haunt_target = targets_near_position[1]
        inst:ListenForEvent("onremove", inst._OnHauntTargetRemoved, inst._haunt_target)
	end
end

local function OnDroppedTarget(inst, data)
    -- If we're blocking retargets but our target went away/died,
    -- allow ourselves to go back to target grabbing again.
    inst.components.timer:StopTimer("block_retargets")
end

-- Timer
local function OnTimerDone(inst, data)
    if data.name == "undo_transparency" then

        if not inst:HasTag("gestalt_hide") then
            inst.components.fader:Fade(0.3, 1.0, 0.75, do_transparency)
            inst.point_filtered:set(false)
        end

        if not inst:HasTag("gestalt") then inst.components.aura:Enable(true) end

        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "transparency")
        inst:RemoveTag("notarget")
        inst._is_transparent = false
    end
end

local function DoShadowBurstBuff(inst, stack)
    local x,y,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("abigail_attack_shadow_fx").Transform:SetPosition(x,y,z)
    local fx = SpawnPrefab("abigail_shadow_buff_fx")
    inst:AddChild(fx)

    if not inst:HasDebuff("abigail_murder_buff") then
        inst:AddDebuff("abigail_murder_buff", "abigail_murder_buff")
        stack = stack-1
    end

    local murder_buff = inst:GetDebuff("abigail_murder_buff")
    local time = GetTaskRemaining(murder_buff.decaytimer)
    murder_buff:murder_buff_OnExtended(math.min( time + stack*TUNING.SKILLS.WENDY.MURDER_BUFF_DURATION,  20*TUNING.SKILLS.WENDY.MURDER_BUFF_DURATION )  )
end

local function calcabigailmaxhealthbonus(inst)
    if inst.components.follower and inst.components.follower.leader and
        inst.components.follower.leader.components.skilltreeupdater and
        inst.components.follower.leader.components.skilltreeupdater:IsActivated("wendy_sisturn_4") then
            return TUNING.SKILLS.WENDY.SISTURN_3_MAX_HEALTH_BOOST + TUNING.SKILLS.WENDY.SISTURN_3_MAX_HEALTH_BOOST
    end

    return TUNING.SKILLS.WENDY.SISTURN_3_MAX_HEALTH_BOOST
end

local function UpdateBonusHealth(inst, newbonus)
    local max = nil
    local calculated_max_health_bonus = calcabigailmaxhealthbonus(inst)

    if inst.bonus_max_health == 0 and newbonus > 0 then
        max = calculated_max_health_bonus
    elseif inst.bonus_max_health > 0 and newbonus <= 0 then
        max = 0
    end

    inst.bonus_max_health = newbonus
    inst:PushEvent("pethealthbar_bonuschange", {
        max = max,
        oldpercent = inst.bonus_max_health/calculated_max_health_bonus,
        newpercent = newbonus/calculated_max_health_bonus,
    })
end

local function AddBonusHealth(inst,val)
    if inst.bonus_max_health < calcabigailmaxhealthbonus(inst) then
        local newmax = math.min(calcabigailmaxhealthbonus(inst), inst.bonus_max_health + val )
        inst:UpdateBonusHealth(newmax)
        local fx = SpawnPrefab("abigail_rising_twinkles_fx")
        inst:AddChild(fx)
    end
    SetMaxHealth(inst)
end

local function OnHealthChanged(inst, data)
    local oldbonus = inst.bonus_max_health

    -- Bonus should only go down through this process. Raising it is handled in AddBonusHealth
    if data.val > inst.base_max_health then
        inst.bonus_max_health = math.min(data.val - inst.base_max_health, oldbonus)
    else
        inst.bonus_max_health = 0
    end

    if inst.bonus_max_health ~= oldbonus then
        UpdateBonusHealth(inst, math.max(0, inst.bonus_max_health ))
    end

    inst.components.health.maxhealth = inst.base_max_health + inst.bonus_max_health
end

local function OnHealthDelta(inst,data)
    if inst:HasTag("gestalt") and data.newpercent < TUNING.ABIGAIL_GESTALT_HIDE_THRESHOLD and not inst:HasTag("gestalt_hide") then
        if inst.components.timer:TimerExists("undo_transparency") then 
            OnTimerDone(inst, {name="undo_transparency"})
        end

        inst.components.health:SetMinHealth(0)
        inst:AddTag("gestalt_hide")
        if not inst._is_transparent then
            inst.components.fader:Fade(1.0, 0.3, 0.75, do_transparency)
            inst.point_filtered:set(true)
        end
    end

    if inst:HasTag("gestalt") and data.newpercent >= TUNING.ABIGAIL_GESTALT_HIDE_THRESHOLD and inst:HasTag("gestalt_hide") then
        inst:RemoveTag("gestalt_hide")
        inst.components.health:SetMinHealth(1)
        if not inst._is_transparent then
            inst.components.fader:Fade(0.3, 1.0, 0.75, do_transparency)
            inst.point_filtered:set(false)
        end
    end
end

local function SetToGestalt(inst)
    inst.SoundEmitter:PlaySound("meta5/abigail/abigail_gestalt_transform_stinger")
    inst:AddTag("gestalt")
    inst.components.aura:Enable(false)
    inst.AnimState:SetBuild( "ghost_abigail_gestalt_build" )

    inst.AnimState:OverrideSymbol("fx_puff2",       "lunarthrall_plant_front",      "fx_puff2")
    inst.AnimState:OverrideSymbol("v1_ball_loop",   "brightmare_gestalt_evolved",   "v1_ball_loop")
    inst.AnimState:OverrideSymbol("v1_embers",      "lunarthrall_plant_front",      "v1_embers")
    inst.AnimState:OverrideSymbol("v1_melt2",       "lunarthrall_plant_front",      "v1_melt2")

    inst.components.combat:SetAttackPeriod(3)

    inst.components.health:SetMinHealth(1)

    local buff = inst.components.debuffable:GetDebuff("super_elixir_buff")

    if buff ~= nil and buff.prefab == "ghostlyelixir_lunar_buff" then
        inst.components.planardamage:RemoveBonus(inst, "ghostlyelixir_lunarbonus")
        inst.components.planardamage:AddBonus(inst, TUNING.SKILLS.WENDY.LUNARELIXIR_DAMAGEBONUS_GESTALT, "ghostlyelixir_lunarbonus")
    end

end

local function SetToNormal(inst)
    inst.SoundEmitter:PlaySound("meta5/abigail/abigail_gestalt_transform_stinger")
    inst:RemoveTag("gestalt")
    inst.components.aura:Enable(true)
    inst.AnimState:SetBuild( "ghost_abigail_build" )

    inst.AnimState:ClearOverrideSymbol("fx_puff2")
    inst.AnimState:ClearOverrideSymbol("v1_ball_loop")
    inst.AnimState:ClearOverrideSymbol("v1_embers")
    inst.AnimState:ClearOverrideSymbol("v1_melt2")

    inst.components.health:SetMinHealth(0)

    inst.components.combat:SetAttackPeriod(4)

    local buff = inst.components.debuffable:GetDebuff("super_elixir_buff")

    if buff ~= nil and buff.prefab == "ghostlyelixir_lunar_buff" then
        inst.components.planardamage:RemoveBonus(inst, "ghostlyelixir_lunarbonus")
        inst.components.planardamage:AddBonus(inst, TUNING.SKILLS.WENDY.LUNARELIXIR_DAMAGEBONUS, "ghostlyelixir_lunarbonus")
    end
end

local function OnSave(inst, data)
    data.bonus_max_health = inst.bonus_max_health
    data.gestalt = inst:HasTag("gestalt")
end

local function onload_bonushealth_task(inst, new_bonus_max_health)
    inst.bonus_max_health = 0
    inst:UpdateBonusHealth(new_bonus_max_health)
end

local function OnLoad(inst, data)
    if data ~= nil then

        if data.gestalt then
            SetToGestalt(inst)
        end

        if data.bonus_max_health then
            inst.bonus_max_health = data.bonus_max_health
            inst:DoTaskInTime(1, onload_bonushealth_task, data.bonus_max_health)
        end
    end
end

local function ChangeToGestalt(inst, togestalt)
    if togestalt then
        if not inst:HasTag("gestalt") then
            inst:PushEvent("gestalt_mutate",{gestalt=true})
        end
    else
        if inst:HasTag("gestalt") then
            inst:PushEvent("gestalt_mutate",{gestalt=false})
        end
    end
end
local function OnPointFilterDirty(inst)
    inst.AnimState:UsePointFiltering(inst.point_filtered:value())
end

-------------------------------------------------------------------------------

-- 生成一个击中效果实体，用于表现阿比盖尔攻击的视觉反馈
local function do_hit_fx(inst)
	local fx = SpawnPrefab("abigail_vex_hit")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

-- 当目标被攻击时触发的回调函数，用于处理特定逻辑
local function on_target_attacked(inst, target, data)
	if data ~= nil and data.attacker ~= nil and data.attacker:HasTag("ghostlyfriend") then
		inst.hitevent:push()
	end
end

-- 定义buff的持续时间，时间到了就移除
local function buff_OnExtended(inst)
	if inst.decaytimer ~= nil then
		inst.decaytimer:Cancel()
	end
	inst.decaytimer = inst:DoTaskInTime(TUNING.ABIGAIL_VEX_DURATION, function() inst.components.debuff:Stop() end)
end

-- 添加buff，inst是药剂
local function buff_OnAttached(inst, target)
	if target ~= nil and target:IsValid() and not target.inlimbo and target.components.combat ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
		target.components.combat.externaldamagetakenmultipliers:SetModifier(inst, TUNING.ABIGAIL_VEX_DAMAGE_MOD)  -- 修改目标受到伤害的倍率

		inst.entity:SetParent(target.entity)  -- 将 buff 的实体设置为目标实体的子对象
		inst.Transform:SetPosition(0, 0, 0)  -- Buff 的位置和运动将自动跟随目标
        -- 让 buff 的显示效果动态适应目标实体的大小
		local s = (1 / target.Transform:GetScale()) * (target:HasTag("largecreature") and 1.6 or 1.2)
		if s ~= 1 and s ~= 0 then
			inst.Transform:SetScale(s, s, s)
		end

		inst:ListenForEvent("attacked", inst._on_target_attacked, target)
	end

	buff_OnExtended(inst)

    inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
end

-- 移除buff
local function buff_OnDetached(inst, target)
	if inst.decaytimer ~= nil then
		inst.decaytimer:Cancel()
		inst.decaytimer = nil

		if target ~= nil and target:IsValid() and target.components.combat ~= nil then
			target.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst)  -- 恢复目标受到伤害的正常倍率
		end

		inst.AnimState:PushAnimation("vex_debuff_pst", false)  -- 播放 buff 移除动画 "vex_debuff_pst"，第二个参数为 false，表示动画播放后不会循环
		inst:ListenForEvent("animqueueover", inst.Remove)  -- 当移除动画播放完毕时，移除buff实体
	end
end

-- 创建一个用于表示阿比盖尔的 Vex debuff（减益效果）的实体
local function abigail_vex_debuff_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("abigail_debuff_fx")
	inst.AnimState:SetBuild("abigail_debuff_fx")

	inst.AnimState:PlayAnimation("vex_debuff_pre")
	inst.AnimState:PushAnimation("vex_debuff_loop", true)
	inst.AnimState:SetFinalOffset(3)

	inst:AddTag("FX")

	inst.hitevent = net_event(inst.GUID, "abigail_vex_debuff.hitevent")

	if not TheNet:IsDedicated() then
        inst:ListenForEvent("abigail_vex_debuff.hitevent", do_hit_fx)
	end

    inst.entity:SetPristine()  -- 实体仅存在于客户端中，不会在服务器上保存

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
	inst._on_target_attacked = function(target, data) on_target_attacked(inst, target, data) end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)

	return inst
end

-------------------------------------------------------------------------------

local function CreateDebuff(name)

    local function do_hit_fx(inst)
        local fx = SpawnPrefab("abigail_vex_hit")
        if name == "abigail_vex_shadow_debuff" then
            fx.AnimState:SetMultColour(0,0,0,1)
            --fx.AnimState:PlayAnimation("vex_lunar_hit_"..math.random(3))
        end
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    local function on_target_attacked(inst, target, data)
        if data ~= nil and data.attacker ~= nil and data.attacker:HasTag("ghostlyfriend") then
            inst.hitevent:push()
        end
    end

    local function buff_OnExtended(inst, target, followsymbol, followoffset, data, buffer)
        if inst.decaytimer ~= nil then
            inst.decaytimer:Cancel()
        end            
        local duration = TUNING.ABIGAIL_VEX_DURATION
        if buffer and buffer:HasTag("gestalt") then
            duration = TUNING.ABIGAIL_VEX_DURATION * TUNING.SKILLS.WENDY.ABIGAIL_GESTALT_VEX_MULT
        end

        inst.decaytimer = inst:DoTaskInTime(duration, function() inst.components.debuff:Stop() end)
    end

    local function buff_OnAttached(inst, target, followsymbol, followoffset, data, buffer)
        if target ~= nil and target:IsValid() and not target.inlimbo and target.components.combat ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
            local mult = TUNING.ABIGAIL_VEX_DAMAGE_MOD
            if name == "abigail_vex_shadow_debuff" then
                mult = TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD
            end
            target.components.combat.externaldamagetakenmultipliers:SetModifier(inst, mult)

            inst.entity:SetParent(target.entity)
            inst.Transform:SetPosition(0, 0, 0)
            local s = (1 / target.Transform:GetScale()) * (target:HasTag("largecreature") and 1.6 or 1.2)
            if s ~= 1 and s ~= 0 then
                inst.Transform:SetScale(s, s, s)
            end

            inst:ListenForEvent("attacked", inst._on_target_attacked, target)
        end

        buff_OnExtended(inst, target, nil, nil, nil, buffer)

        inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
    end

    local function buff_OnDetached(inst, target)
        if inst.decaytimer ~= nil then
            inst.decaytimer:Cancel()
            inst.decaytimer = nil

            if target ~= nil and target:IsValid() and target.components.combat ~= nil then
                target.components.combat.externaldamagetakenmultipliers:RemoveModifier(inst)
            end

            inst.AnimState:PushAnimation("vex_debuff_pst", false)
            inst:ListenForEvent("animqueueover", inst.Remove)
        end
    end

    local function abigail_vex_debuff_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("abigail_debuff_fx")
        inst.AnimState:SetBuild("abigail_debuff_fx")

        inst.AnimState:PlayAnimation("vex_debuff_pre")
        inst.AnimState:PushAnimation("vex_debuff_loop", true)
        inst.AnimState:SetFinalOffset(3)

        inst:AddTag("FX")

        inst.hitevent = net_event(inst.GUID, "abigail_vex_debuff.hitevent")

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("abigail_vex_debuff.hitevent", do_hit_fx)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst._on_target_attacked = function(target, data) on_target_attacked(inst, target, data) end

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(buff_OnAttached)
        inst.components.debuff:SetDetachedFn(buff_OnDetached)
        inst.components.debuff:SetExtendedFn(buff_OnExtended)
        inst.buff_OnExtended = buff_OnExtended

        return inst
    end

    return Prefab(name, abigail_vex_debuff_fn, {Asset("ANIM", "anim/abigail_debuff_fx.zip")}, {"abigail_vex_hit"} )
end

--------------------------------------------------------------------------------

local function murder_buff_OnExtended(inst, duration)
    if inst.decaytimer ~= nil then
        inst.decaytimer:Cancel()
    end
    inst.decaytimer = inst:DoTaskInTime(duration or TUNING.SKILLS.WENDY.MURDER_BUFF_DURATION , function() inst.components.debuff:Stop() end)
end

local function murder_buff_OnAttached(inst, target)
    murder_buff_OnExtended(inst)
    if target and target:IsValid() then

        UpdateDamage(target)

        target.AnimState:SetBuild( "ghost_abigail_shadow_build" )

        if target.components.aura and target.components.aura.applying then
            target:PushEvent("stopaura")
            target:PushEvent("startaura")
        end

        local fx = SpawnPrefab("shadow_puff_large_front")
        fx.Transform:SetScale(1.2,1.2,1.2)
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())

        target.components.planardefense:AddBonus(inst, TUNING.SKILLS.WENDY.MURDER_DEFENSE_BUFF, "wendymurderbuff")

        inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
    end
end

local function murder_buff_OnDetached(inst, target)
    if inst.decaytimer then
        inst.decaytimer:Cancel()
        inst.decaytimer = nil

        if target and target:IsValid() then

            UpdateDamage(target)

            target.AnimState:SetBuild( "ghost_abigail_build" )

            if target.components.aura and target.components.aura.applying then
                target:PushEvent("stopaura")
                target:PushEvent("startaura")
            end

            local fx = SpawnPrefab("shadow_puff_large_front")
            fx.Transform:SetScale(1.2,1.2,1.2)
            fx.Transform:SetPosition(target.Transform:GetWorldPosition())

            target.components.planardefense:RemoveBonus(inst, "wendymurderbuff")
        end
    end
end

local function abigail_murder_buff_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(murder_buff_OnAttached)
    inst.components.debuff:SetDetachedFn(murder_buff_OnDetached)
    inst.components.debuff:SetExtendedFn(murder_buff_OnExtended)

    inst.murder_buff_OnExtended = murder_buff_OnExtended

    return inst
end

-------------------------------------------------------------------------------

-- 创建一个表示阿比盖尔 Vex 减益效果命中时的视觉特效实体，并为其设置相应的动画和事件
local function abigail_vex_hit_fn()
    local inst = CreateEntity()

	inst:AddTag("CLASSIFIED")
    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

	inst.AnimState:SetBank("abigail_debuff_fx")
	inst.AnimState:SetBuild("abigail_debuff_fx")

	inst.AnimState:PlayAnimation("vex_hit")
	inst.AnimState:SetFinalOffset(3)

	inst:AddTag("FX")

    inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("abigail", fn, assets, prefabs),
	   Prefab("abigail_retaliation", retaliationattack_fn, {Asset("ANIM", "anim/abigail_shield.zip")} ),
	   Prefab("abigail_vex_debuff", abigail_vex_debuff_fn, {Asset("ANIM", "anim/abigail_debuff_fx.zip")}, {"abigail_vex_hit"} ),
	   Prefab("abigail_vex_hit", abigail_vex_hit_fn, {Asset("ANIM", "anim/abigail_debuff_fx.zip")} )

return Prefab("abigail", fn, assets, prefabs),
	   Prefab("abigail_retaliation", retaliationattack_fn, {Asset("ANIM", "anim/abigail_shield.zip")} ),
       CreateDebuff("abigail_vex_debuff"),
       CreateDebuff("abigail_vex_shadow_debuff"),
	   Prefab("abigail_vex_hit", abigail_vex_hit_fn, {Asset("ANIM", "anim/abigail_debuff_fx.zip")} ),
       Prefab("abigail_murder_buff", abigail_murder_buff_fn)