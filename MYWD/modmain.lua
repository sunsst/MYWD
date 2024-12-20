MYWDG = {}
--------------------------------------------------------------------------------------------------------

-- 图集
local atlas = {
    "skilltree_bg", -- 技能树背景图
    "mywd_icon",    -- 图标项

    "inventoryimages2",
    "inventoryimages3",
    "inventoryimages1",
    "skilltree_icons",
    "skilltree4",
    "hud2"
}

--------------------------------------------------------------------------------------------------------

-- 动画
local anims = {
    "mywd_ghostly_elixirs",    -- 灵体草药的放置动画
    "spell_icons_wendy",       -- 技能图标
    "ui_elixir_container_3x3", -- 药剂背包

    "mywd_abigail"
}

--------------------------------------------------------------------------------------------------------

-- 预制件
local prefabs = {
    "reticuleaoe",             -- 一个新的瞄准特效（其实是旧的贴图）
    "wendy",                   -- 新的温蒂
    "abigail",                 -- 新的阿比
    "abigail_flower",          -- 新的阿比盖尔的花
    "sisturn",                 -- 新的姐妹骨灰盒
    "smallghost",              -- 新的小惊吓
    "gravestone",              -- 新的墓碑
    "petals",                  -- 新的花瓣
    "ghost",                   -- 新的鬼魂
    "ghostly_elixirs",         -- 新的药剂
    "hats",                    -- 真·新帽子
    "elixir_container",        -- 真·新的花篮
    "wendy_resurrectiongrave", -- 真·新祭坛？
    "wendy_recipe_gravestone", -- 真·新墓碑
    "ghostvision_buff"         -- 真·新一个buff
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
    "recipes",

    -- 测试用的库，到时候记得去掉
    "testutil/show_range",
    "testutil/add_text",
    "testutil/make_anim_tester",
    "testutil/put_all_anims",

    -- 来自测试服的变量参数
    "from_test/vars",
    "from_test/skilltree_wendy",
    "from_test/actions",
    "from_test/recipes",
    "from_test/other",

    -- "skills",
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
