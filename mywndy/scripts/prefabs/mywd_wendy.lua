local my_wendy = require("prefabs/wendy")
local old_fn = my_wendy.fn


local function OnAttacked(inst, data)
    print("MYWD_ATK!!:", inst.components.pethealthbar.pet)
    if not inst.components.pethealthbar.pet then return end
    print("MYWD_ATK!!!")
    inst.abigail_bullet.owner = inst.components.pethealthbar.pet
    inst.abigail_bullet:Throw(data.target)
end

local ANCIENTFRUIT_NIGHTVISION_COLOURCUBES =
{
    day = "images/colour_cubes/nightvision_fruit_cc.tex",
    dusk = "images/colour_cubes/nightvision_fruit_cc.tex",
    night = "images/colour_cubes/nightvision_fruit_cc.tex",
    full_moon = "images/colour_cubes/nightvision_fruit_cc.tex",

    nightvision_fruit = true, -- NOTES(DiogoW): Here for convinience.
}
my_wendy.fn = function()
    local inst = old_fn()


    if not TheWorld.ismastersim then
        return inst
    end

    inst.abigail_bullet = SpawnPrefab("abigail_bullet")
    inst:ListenForEvent("onattackother", OnAttacked)


    inst:AddComponent("aura")
    inst.components.aura.radius = 4
    inst.components.aura.tickperiod = 1
    inst.components.aura.ignoreallies = true


    return inst
end


TheInput:AddKeyHandler(function(key, down)
    local inst = ThePlayer
    if inst and key == KEY_INSERT then
        inst.components.aura:Enable(down)
        if down then
            inst.components.playervision:PushForcedNightVision(inst, 1, ANCIENTFRUIT_NIGHTVISION_COLOURCUBES,
                true)
        else
            inst.components.playervision:PopForcedNightVision(inst)
        end
    end
end)



return my_wendy
