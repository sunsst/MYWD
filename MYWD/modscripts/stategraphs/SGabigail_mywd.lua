local function sg_fn(self)
    print("MYWDLAB_SG_OK")

    -- 关闭范围攻击
    self.states["appear"].onexit = function(inst)
        inst.components.aura:Enable(false)
        -- inst.components.aura:Enable(true)
        inst.components.health:SetInvincible(false)
        if inst._playerlink ~= nil then
            inst._playerlink.components.ghostlybond:SummonComplete()
        end
    end
end

local attack_speed = TUNING.MYWD.ABIGAIL_MOON_IMPACT_DISTANCE / TUNING.MYWD.ABIGAIL_MOON_IMPACT_DURATUION

AddStategraphPostInit("abigail", sg_fn)

AddStategraphState("abigail", GLOBAL.State {
    name = "moon_hit",
    tags = { "busy", "noattack", "attack", "jumping" },

    onenter = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl_one_shot")
        inst.AnimState:PlayAnimation("hit")


        -- 解除碰撞跟蝴蝶一样
        GLOBAL.MakeTinyFlyingCharacterPhysics(inst, inst.Physics:GetMass(), inst.Physics:GetRadius())

        inst.components.locomotor:Stop()
        if inst.components.combat.target ~= nil then
            inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
        end
        inst.components.combat:StartAttack()
    end,

    onexit = function(inst)
        -- 恢复原样
        inst.Physics:ClearMotorVelOverride()
        GLOBAL.MakeGhostPhysics(inst, inst.Physics:GetMass(), inst.Physics:GetRadius())
        inst.components.locomotor:Stop()
    end,


    timeline =
    {
        GLOBAL.TimeEvent(0, function(inst)
            inst.components.locomotor:Stop()
            inst.Physics:SetMotorVelOverride(attack_speed, 0, 0)
        end),
        GLOBAL.TimeEvent(TUNING.MYWD.ABIGAIL_MOON_IMPACT_DURATUION, function(inst)
            inst.Physics:ClearMotorVelOverride()
        end),
    },

    events =
    {
        GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("moon_hit_over")
            end
        end),
    },
})

AddStategraphState("abigail", GLOBAL.State {
    name = "moon_hit_over",
    tags = { "busy", "noattack", "jumping" },

    onenter = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/howl_one_shot")
        inst.AnimState:PlayAnimation("flower_change")
    end,

    timeline =
    {

        GLOBAL.TimeEvent(0.25, function(inst)
            inst:Hide()
            inst.Physics:Teleport(inst._playerlink.Transform:GetWorldPosition())
        end),
        GLOBAL.TimeEvent(0.75, function(inst)
            inst:Show()
        end),
    },

    events =
    {
        GLOBAL.EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
})

AddStategraphEvent("abigail", GLOBAL.EventHandler("onmoon_hit", function(inst)
    inst.sg:GoToState("moon_hit")
    GLOBAL.c_announce("EVENET ONMOONHIT")
    ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_IMPACT_DISTANCE)
    ShowRange(inst, TUNING.MYWD.ABIGAIL_MOON_IMPACT_GUARD_RANGE)
end))
