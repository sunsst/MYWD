Assets = {
    Asset("ATLAS", "images/wendy_skilltree_bg.xml"),
    Asset("ATLAS", "images/my_icon.xml"),
    Asset("ANIM", "anim/mywd_status_abigail.zip"),

    Asset("ANIM", "anim/mywd_abigail.zip"),
    Asset("ATLAS", "images/mywd_ghostly_elixirs.xml"),

    Asset("ANIM", "anim/yc.zip"),
}
PrefabFiles = {
    "mywd_ghostly_elixirs",
    "mywd_abigail",
    "mywd_wendy",
    "heart_fx",

    "abigail_bullet",

}


modimport("modscripts/hook")

modimport("languages/chs")
modimport("modscripts/skilltree_mywd")
modimport("modscripts/tuning")

modimport("modscripts/recipes.lua")


AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then return inst end

    local fx = GLOBAL.SpawnPrefab("heartfx") -- 生成一个特效
    fx.entity:SetParent(inst.entity)         -- 设置成跟随玩家
end)
