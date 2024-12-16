--------------------------------------------------------------------------------------------------------

-- 图集
local atlas = {
    "bg/skilltree_bg",
    "icon/skilltree_icon",
}

--------------------------------------------------------------------------------------------------------

-- 动画
local anims = {
    "mywd_ghostly_elixirs", -- 灵体草药的放置动画
}

--------------------------------------------------------------------------------------------------------

-- 预制件
local prefabs = {
    "mywd_ghostly_elixirs", -- 灵体草药
}

--------------------------------------------------------------------------------------------------------

-- 文字变量
local languages = {
    "chs",
}

--------------------------------------------------------------------------------------------------------

-- 模组脚本
local modscripts = {
    "tuning",
    "skills",
}

--------------------------------------------------------------------------------------------------------

Assets = {}
PrefabFiles = prefabs

local atlas_len = #atlas
for i, name in ipairs(atlas) do
    Assets[i] = Asset("ATLAS", "images/" .. name .. ".xml")
end

for i, name in ipairs(anims) do
    Assets[atlas_len + i] = Asset("ANIM", "anim/" .. name .. ".zip")
end

for _, name in ipairs(languages) do
    modimport("languages/" .. name .. ".lua")
end


for _, name in ipairs(modscripts) do
    modimport("modscripts/" .. name .. ".lua")
end

anims = nil
atlas = nil
prefabs = nil
modscripts = nil
languages = nil
