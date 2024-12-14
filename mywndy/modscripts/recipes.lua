AddCharacterRecipe("ghostlyelixir_dream",
    { Ingredient("ghostflower", 1) },
    GLOBAL.TECH.NONE,
    {
        builder_skill = "mywd_wdga_1",
        atlas = "images/mywd_ghostly_elixirs.xml",
        -- product = "ghostlyelixir_dream",
        builder_tag = "elixirbrewer"
    },
    { "CHARACTER" })


print("MYWD:!!", "..", GLOBAL.TheSkillTree)
