--------------------------------------------------------------------------------------------------------------------
-- MYWD:下面代码复制粘贴自测试服代码不要动，等更新了可以删了

local function elixir_numtogive(recipe, doer)
    print("MYWD:elixir_numtogive 被正常调用")
    local total = 1
    if doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("wendy_potion_yield") then
        if math.random() < 0.3 then
            total = total + 1
        end
        if math.random() < 0.3 then
            total = total + 1
        end
        if total > 1 then
            doer:PushEvent("craftedextraelixir", total)
        end
    end
    return total
end

local f1 = function(recipe)
    recipe.override_numtogive_fn = elixir_numtogive
    recipe.no_deconstruction = true
end

local rp2 = resolvefilepath("images/inventoryimages2.xml")
local rp3 = resolvefilepath("images/inventoryimages3.xml")
local rp1 = resolvefilepath("images/inventoryimages1.xml")
AddRecipePostInit("ghostlyelixir_slowregen", f1)
AddRecipePostInit("ghostlyelixir_fastregen", f1)
AddRecipePostInit("ghostlyelixir_shield", f1)
AddRecipePostInit("ghostlyelixir_retaliation", f1)
AddRecipePostInit("ghostlyelixir_attack", f1)
AddRecipePostInit("ghostlyelixir_speed", f1)
AddCharacterRecipe("ghostlyelixir_revive", { Ingredient("forgetmelots", 1), Ingredient("ghostflower", 3) }, TECH.NONE,
    {

        builder_skill = "wendy_potion_revive",
        override_numtogive_fn =
            elixir_numtogive,
        no_deconstruction = true
    })
AddCharacterRecipe("ghostlyelixir_shadow", { Ingredient("horrorfuel", 1), Ingredient("ghostflower", 3) }, TECH.NONE,
    {

        builder_skill = "wendy_shadow_2",
        override_numtogive_fn =
            elixir_numtogive,
        no_deconstruction = true
    })
AddCharacterRecipe("ghostlyelixir_lunar", { Ingredient("purebrilliance", 1), Ingredient("ghostflower", 3) }, TECH.NONE,
    {

        builder_skill = "wendy_lunar_2",
        override_numtogive_fn =
            elixir_numtogive,
        no_deconstruction = true
    })
AddCharacterRecipe("wendy_gravestone", { Ingredient("cutstone", 1), Ingredient("petals_evil", 4) }, TECH.NONE,
    {

        builder_skill = "wendy_makegravemounds",
        product = "wendy_recipe_gravestone",
        placer =
        "wendy_recipe_gravestone_placer",
        min_spacing = 0,
        no_deconstruction = true,
        image = "dug_gravestone.tex"
    })
AddCharacterRecipe("elixir_container", { Ingredient("twigs", 6), Ingredient("boards", 1), Ingredient("silk", 4) },
    TECH.NONE,
    { builder_skill = "wendy_potion_container" })
AddCharacterRecipe("ghostflowerhat", { Ingredient("ghostflower", 6) }, TECH.NONE,
    { builder_skill = "wendy_ghostflower_hat" })
AddCharacterRecipe("wendy_butterfly", { Ingredient("ghostflower", 2), Ingredient("butterflywings", 1) }, TECH.NONE,
    {

        builder_skill = "wendy_ghostflower_butterfly",
        product =
        "butterfly",
        image = "butterfly.tex"
    })
AddCharacterRecipe("wendy_resurrectiongrave",
    { Ingredient("ghostflower", 10), Ingredient("cutstone", 1), Ingredient(CHARACTER_INGREDIENT.HEALTH,
        TUNING.EFFIGY_HEALTH_PENALTY) }, TECH.NONE,
    {

        builder_skill = "wendy_ghostflower_grave",
        placer =
        "wendy_resurrectiongraveplacer"
    })



local f2 = function(inst)
    inst.components.inventoryitem.atlasname = rp2
end

local f3 = function(inst)
    inst.components.inventoryitem.atlasname = rp3
end
local f1 = function(inst)
    inst.components.inventoryitem.atlasname = rp1
end
AddPrefabPostInit("ghostlyelixir_revive", f2)
AddPrefabPostInit("ghostlyelixir_shadow", f2)
AddPrefabPostInit("ghostlyelixir_lunar", f2)

AddPrefabPostInit("slingshot", f3)
AddPrefabPostInit("slingshotammo_rock", f3)
AddPrefabPostInit("slingshotammo_gold", f3)
AddPrefabPostInit("slingshotammo_marble", f3)
AddPrefabPostInit("slingshotammo_poop", f3)
AddPrefabPostInit("slingshotammo_freeze", f3)
AddPrefabPostInit("slingshotammo_slow", f3)
AddPrefabPostInit("slingshotammo_thulecite", f3)
-- AddPrefabPostInit("wendy_resurrectiongrave", f3)

AddPrefabPostInit("elixir_container", f1)
AddPrefabPostInit("dug_gravestone", f1)


local ff2 = function(recipe)
    recipe.atlas = rp2
end
local ff3 = function(recipe)
    recipe.atlas = rp3
end
local ff1 = function(recipe)
    recipe.atlas = rp1
end

AddRecipePostInit("ghostlyelixir_revive", ff2)
AddRecipePostInit("ghostlyelixir_shadow", ff2)
AddRecipePostInit("ghostlyelixir_lunar", ff2)
AddRecipePostInit("ghostflowerhat", ff2)


AddRecipePostInit("wendy_resurrectiongrave", ff3)

AddRecipePostInit("wendy_gravestone", ff1)
AddRecipePostInit("elixir_container", ff1)


AddRecipePostInit("slingshot", ff3)
AddRecipePostInit("slingshotammo_rock", ff3)
AddRecipePostInit("slingshotammo_gold", ff3)
AddRecipePostInit("slingshotammo_marble", ff3)
AddRecipePostInit("slingshotammo_poop", ff3)
AddRecipePostInit("slingshotammo_freeze", ff3)
AddRecipePostInit("slingshotammo_slow", ff3)
AddRecipePostInit("slingshotammo_thulecite", ff3)
