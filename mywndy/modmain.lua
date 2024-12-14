Assets = {
    Asset("ATLAS", "images/wendy_skilltree_bg.xml"),
    Asset("ATLAS", "images/my_icon.xml"),
    Asset("ANIM", "anim/mywd_status_abigail.zip"),

    Asset("ANIM", "anim/mywd_abigail.zip")
}
PrefabFiles = {
    "mywd_ghostly_elixirs",
    "mywd_abigail",
    "mywd_wendy",


    "abigail_bullet",

}


modimport("modscripts/hook")

modimport("languages/chs")
modimport("modscripts/skilltree_mywd")
modimport("modscripts/tuning")

modimport("modscripts/recipes.lua")



-- GLOBAL.TheInput:AddKeyHandler(function(key, down)
--     if down and key == string.byte(';') and GLOBAL.AllPlayers[1] ~= nil then
--         local x, y, z = GLOBAL.AllPlayers[1].Transform:GetWorldPosition()
--         local entities = GLOBAL.TheSim:FindEntities(x, y, z, 4, {
--             "butterfly"
--         })

--         GLOBAL.c_announce(type(entities))
--         GLOBAL.c_announce(#entities)
--     end
-- end)
