-- 在这个文件添加制作配方，记得去chs文件添加名字


-- 创建温蒂专属制作配方，都字面意思，不要哪个参数不填就行
-- 比如：AddWendyRecipe("ghostlyelixir_moon", { Ingredient("moon_tree_blossom", 1) }, "mywd_wdga_1", "elixirbrewer")
local function AddWendyRecipe(prefab, ingredients, builder_skill, builder_tag)
    RegisterScrapbookIconAtlas("images/mywd_icon.xml", prefab .. ".tex")
    AddCharacterRecipe(prefab, ingredients, TECH.NONE, {
            atlas = GetScrapbookIconAtlas(prefab .. ".tex"),
            builder_tag = builder_tag,
            product = prefab,
            builder_skill = builder_skill
        },
        { "CHARACTER" })
end


-- 示例：添加月亮药剂的配方
-- AddWendyRecipe("ghostlyelixir_moon", {
--     Ingredient("moon_tree_blossom", 1),
--     Ingredient("moonbutterflywings", 1),
--     Ingredient("ghostflower", 1),
--     Ingredient("purebrilliance", 1),
-- }, "mywd_wdga_1", "elixirbrewer")
