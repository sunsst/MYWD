local SPELLBOOK_RADIUS = 100

local function post_fn(inst)
    local spellbook = inst:AddComponent("spellbook")
    spellbook:SetRequiredTag("ghostlyfriend")
    spellbook:SetRadius(SPELLBOOK_RADIUS)
    spellbook:SetFocusRadius(SPELLBOOK_RADIUS)
    spellbook:SetItems(nil)
    spellbook:SetOnOpenFn(function() end)
    spellbook:SetOnCloseFn(function() end)
    spellbook.closesound = "meta3/willow/ember_container_close"
end


AddPrefabPostInit("abigail_flower", post_fn)
