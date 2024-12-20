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
    "spell_icons_wendy",    -- 技能书图标
}

--------------------------------------------------------------------------------------------------------

-- 预制件
local prefabs = {
    "mywd_ghostly_elixirs", -- 灵体草药
    "wendy",
    "mywd_reticuleaoe",
    "abigail",
    "abigail_flower"
}

--------------------------------------------------------------------------------------------------------

-- 文字变量
local languages = {
    "chs",
}

--------------------------------------------------------------------------------------------------------

-- 模组脚本
local modscripts = {
    -- 设置全局变量的文件，别动它的位置
    "menv",

    -- 基本的全局变量设置
    "tuning",
    "skills",
    "recipes",

    -- 测试用的库，到时候记得去掉
    "testutil/show_range",
    "testutil/add_text",
    "testutil/make_anim_tester",
    "testutil/put_all_anims",

    -- 这是从测试服复制过来的代码
    "from_test/actions",
    "from_test/SGwilson",
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
