MYWDG = {}
--------------------------------------------------------------------------------------------------------

-- 图集
local atlas = {
    "skilltree_bg", -- 技能树背景图
    "mywd_icon",    -- 图标项
}

--------------------------------------------------------------------------------------------------------

-- 动画
local anims = {
    "mywd_ghostly_elixirs", -- 灵体草药的放置动画
    "spell_icons_wendy",    -- 技能图标

    "mywd_abigail"
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
    "recipes",

    -- 测试用的库，到时候记得删了
    "testutil/show_range",
    "testutil/add_text",
    "testutil/make_anim_tester",
    "testutil/put_all_anims",

    -- 阿比盖尔与温蒂
    -- "stategraphs/SGabigail_mywd.lua",
    "prefabs/mywd_abigail",

    -- "prefabs/mywd_ghostcommand_defs", -- 温蒂技能模组，必须在花的修改之前
    "prefabs/mywd_abigail_flower" -- 阿比盖尔的花修改
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
