local function hookPetHealthBadge()
    local PetHealthBadge = require("widgets/pethealthbadge")
    local ctrol = PetHealthBadge._ctor
    PetHealthBadge._ctor = function(obj, ...)
        ctrol(obj, ...)
        obj.default_symbol_build = "mywd_status_abigail"
    end
end
hookPetHealthBadge()
-- 给新buff添加阿比盖尔的血量图标下的药剂徽章

-- 阿比盖尔不许攻击
local function hookAbigailCantAttack()
    require("stategraphs/SGabigail").states["appear"].onexit = function(inst)
        inst.components.aura:Enable(false)
        inst.components.health:SetInvincible(false)
        if inst._playerlink ~= nil then
            inst._playerlink.components.ghostlybond:SummonComplete()
        end
    end
end
hookAbigailCantAttack()

-- 阿比盖尔不许追敌人
local function hookAbigailCantFight()
    local brain = require("brains/abigailbrain")

    local old_fn = brain.OnStart
    ---@diagnostic disable-next-line: duplicate-set-field
    brain.OnStart = function(self)
        old_fn(self)
        local t = self.bt.root.children[1].children[2]

        table.remove(t.children, 3)
    end
end
hookAbigailCantFight()


-- 阿比盖尔添加抓蝴蝶动作
local function hookAbigailCatch()
    local brain = require("brains/abigailbrain")

    local old_fn = brain.OnStart


    ---@diagnostic disable-next-line: duplicate-set-field
    brain.OnStart = function(self)
        old_fn(self)
        local inst = self.inst

        local last_time = -999
        local node = GLOBAL.ConditionNode(function()
            local now_time = GLOBAL.GetTime()
            if now_time - last_time < TUNING.MYWD_ABIGAIL_CATCHBBUTTERFLY_CWAITTIME then
                return false
            end

            local x, y, z = inst.Transform:GetWorldPosition()

            local min = nil
            local min_e = nil
            for _, e in ipairs(TheSim:FindEntities(x, y, z, 32, { "butterfly" }, { "INLIMBO" })) do
                if not e:IsInLimbo() and e:IsValid() then
                    local n = inst:GetDistanceSqToInst(e)
                    if not min then
                        min = n
                        min_e = e
                    elseif n < min then
                        min = n
                        min_e = e
                    end
                end
            end

            if min_e and inst._playerlink then
                GLOBAL.c_announce("阿比盖尔抓了一只蝴蝶并送给你")
                inst._playerlink.components.inventory:GiveItem(min_e)
                last_time = GLOBAL.GetTime()
                return true
            end
            return false
        end, "Catch Butterfly")
        local children = self.bt.root.children[1].children[2].children
        table.insert(children, #children, node)
    end
end
hookAbigailCatch()
