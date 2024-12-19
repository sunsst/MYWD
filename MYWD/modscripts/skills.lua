local orders =
{
    -- { "ghost",  { 136, 210 } },
    -- { "heart",  { 136 + 40, 210 } },
    -- { "flower", { 136 + 80, 210 } },
    { "mywd_moon",        { -214, 210 } },
    { "mywd_shadow",      { -214 + 50, 210 } },
    { "mywd_ghost",       { -214 + 100, 210 } },
    { "mywd_grave",       { -214 + 150, 210 } },
    { "mywd_sisturn",     { -214 + 200, 210 } },
    { "mywd_elixir",      { -214 + 250, 210 } },
    { "mywd_small_ghost", { -214 + 300, 210 } },
    { "mywd_altar",       { -214 + 350, 210 } },
    { "mywd_petal",       { -214 + 400, 210 } },
}

--------------------------------------------------------------------------------------------------


local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- 月亮线 5
        mywd_moon_lock_1   = {
            -- moon 1
            desc = STRINGS.SKILLTREE.MYWD.MYWD_MOON_LOCK_1_DESC, -- 月亮线
            pos = { -214, 180 },
            group = "mywd_moon",
            tags = { "mywd_moon", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            connects = {
                "mywd_moon_lock_2",
            },
            defaultfocus = true
        },
        mywd_moon_lock_2   = {
            -- moon 2
            desc = STRINGS.SKILLTREE.MYWD.MYWD_MOON_LOCK_2_DESC, -- 月亮线
            pos = { -214, 180 - 40 },
            group = "mywd_moon",
            tags = { "mywd_moon", "lock" },
            lock_open = function(prefabname, activatedskills, readonly)
                -- MYWD:锁一下看看效果
                -- if SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills) == 0 then
                --     return true
                -- end
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "mywd_moon_1",
            },
        },
        mywd_moon_1        = {
            -- moon 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_MOON_1_TITLE, -- 月亮线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_MOON_1_DESC,   -- 月亮线
            icon = "my_skill_icon",
            pos = { -214, 180 - 80 },
            group = "mywd_moon",
            tags = { "mywd_moon" },
            locks = { "mywd_moon_lock_1", "mywd_moon_lock_2" },
            connects = {
                "mywd_moon_2",
            },
        },
        mywd_moon_2        = {
            -- moon 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_MOON_2_TITLE, -- 月亮线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_MOON_2_DESC,   -- 月亮线
            icon = "my_skill_icon",
            pos = { -214, 180 - 120 },
            group = "mywd_moon",
            tags = { "mywd_moon" },
        },
        -----------------------------------------------------------------------------

        --暗影线 5
        mywd_shadow_lock_1 = {
            -- shadow 1
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SHADOW_LOCK_1_DESC, -- 暗影线
            pos = { -164, 180 },
            group = "mywd_shadow",
            tags = { "mywd_shadow", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "mywd_shadow_lock_2",
            },
        },
        mywd_shadow_lock_2 = {
            -- shadow 2
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SHADOW_LOCK_2_DESC, -- 暗影线
            pos = { -164, 180 - 40 },
            group = "mywd_shadow",
            tags = { "mywd_shadow", "lock" },
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                    return true
                end
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "mywd_shadow_1",
            },
        },
        mywd_shadow_1      = {
            -- shadow 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_SHADOW_1_TITLE, -- 暗影线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SHADOW_1_DESC,   -- 暗影线
            icon = "my_skill_icon",
            pos = { -164, 180 - 80 },
            group = "mywd_shadow",
            tags = { "mywd_shadow" },
            locks = { "mywd_shadow_lock_1", "mywd_shadow_lock_2" },
            connects = {
                "mywd_shadow_2",
            },
        },
        mywd_shadow_2      = {
            -- shadow 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_SHADOW_2_TITLE, -- 暗影线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SHADOW_2_DESC,   -- 暗影线
            icon = "my_skill_icon",
            pos = { -164, 180 - 120 },
            group = "mywd_shadow",
            tags = { "mywd_shadow" },
        },

        -----------------------------------------------------------------------------

        --鬼魂线 4
        mywd_ghost_1       = {
            -- ghost 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_1_TITLE, -- 鬼魂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_1_DESC,   -- 鬼魂线
            icon = "my_skill_icon",
            pos = { -114, 180 },
            group = "mywd_ghost",
            tags = { "mywd_ghost" },
            root = "true",
            connects = {
                "mywd_ghost_2"
            },
        },
        mywd_ghost_2       = {
            -- ghost 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_2_TITLE, -- 鬼魂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_2_DESC,   -- 鬼魂线
            icon = "my_skill_icon",
            pos = { -114, 180 - 40 },
            group = "mywd_ghost",
            tags = { "mywd_ghost" },
            connects = {
                "mywd_ghost_3"
            },
        },
        mywd_ghost_3       = {
            -- ghost 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_3_TITLE, -- 鬼魂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_3_DESC,   -- 鬼魂线
            icon = "my_skill_icon",
            pos = { -114, 180 - 80 },
            group = "mywd_ghost",
            tags = { "mywd_ghost" },
            connects = {
                "mywd_ghost_4"
            },
        },
        mywd_ghost_4       = {
            -- ghost 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_3_TITLE, -- 鬼魂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_GHOST_3_DESC,   -- 鬼魂线
            icon = "my_skill_icon",
            pos = { -114, 180 - 120 },
            group = "mywd_ghost",
            tags = { "mywd_ghost" },
        },

        -----------------------------------------------------------------------------

        --祭坛线线 2
        mywd_grave_1       = {
            -- grave 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_GRAVE_1_TITLE, -- 祭坛线线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_GRAVE_1_DESC,   -- 祭坛线线
            icon = "my_skill_icon",
            pos = { -64, 180 },
            group = "mywd_grave",
            tags = { "mywd_grave" },
            root = "true",
            connects = {
                "mywd_grave_2"
            },
        },
        mywd_grave_2       = {
            -- grave 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_GRAVE_2_TITLE, -- 祭坛线线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_GRAVE_2_DESC,   -- 祭坛线线
            icon = "my_skill_icon",
            pos = { -64, 180 - 40 },
            group = "mywd_grave",
            tags = { "mywd_grave" },
        },

        -----------------------------------------------------------------------------

        --骨灰罐线 3
        mywd_sisturn_1     = {
            -- sisturn 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_SISTURN_1_TITLE, -- 骨灰罐线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SISTURN_1_DESC,   -- 骨灰罐线
            icon = "my_skill_icon",
            pos = { -14, 180 },
            group = "mywd_sisturn",
            tags = { "mywd_sisturn" },
            root = "true",
            connects = {
                "mywd_sisturn_2"
            },
        },
        mywd_sisturn_2     = {
            -- sisturn 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_SISTURN_2_TITLE, -- 骨灰罐线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SISTURN_2_DESC,   -- 骨灰罐线
            icon = "my_skill_icon",
            pos = { -14, 180 - 40 },
            group = "mywd_sisturn",
            tags = { "mywd_sisturn" },
            connects = {
                "mywd_sisturn_3"
            },
        },
        mywd_sisturn_3     = {
            -- sisturn 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_SISTURN_3_TITLE, -- 骨灰罐线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SISTURN_3_DESC,   -- 骨灰罐线
            icon = "my_skill_icon",
            pos = { -14, 180 - 80 },
            group = "mywd_sisturn",
            tags = { "mywd_sisturn" },
        },

        -----------------------------------------------------------------------------

        --药剂线 5
        mywd_elixir_1      = {
            -- elixir 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_1_TITLE, -- 药剂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_1_DESC,   -- 药剂线
            icon = "my_skill_icon",
            pos = { 36, 180 },
            group = "mywd_elixir",
            tags = { "mywd_elixir" },
            root = "true",
            connects = {
                "mywd_elixir_2"
            },
        },
        mywd_elixir_2      = {
            -- elixir 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_2_TITLE, -- 药剂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_2_DESC,   -- 药剂线
            icon = "my_skill_icon",
            pos = { 36, 180 - 40 },
            group = "mywd_elixir",
            tags = { "mywd_elixir" },
            connects = {
                "mywd_elixir_3"
            },
        },
        mywd_elixir_3      = {
            -- elixir 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_3_TITLE, -- 药剂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_3_DESC,   -- 药剂线
            icon = "my_skill_icon",
            pos = { 36, 180 - 80 },
            group = "mywd_elixir",
            tags = { "mywd_elixir" },
            connects = {
                "mywd_elixir_4"
            },
        },
        mywd_elixir_4      = {
            -- elixir 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_4_TITLE, -- 药剂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_4_DESC,   -- 药剂线
            icon = "my_skill_icon",
            pos = { 36, 180 - 120 },
            group = "mywd_elixir",
            tags = { "mywd_elixir" },
            connects = {
                "mywd_elixir_5"
            },
        },
        mywd_elixir_5      = {
            -- elixir 5
            title = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_5_TITLE, -- 药剂线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ELIXIR_5_DESC,   -- 药剂线
            icon = "my_skill_icon",
            pos = { 36, 180 - 160 },
            group = "mywd_elixir",
            tags = { "mywd_elixir" },
        },

        -----------------------------------------------------------------------------

        --小惊吓线 3
        mywd_small_ghost_1 = {
            -- small_ghost 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_SMALL_GHOST_1_TITLE, -- 小惊吓线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SMALL_GHOST_1_DESC,   -- 小惊吓线
            icon = "my_skill_icon",
            pos = { 86, 180 },
            group = "mywd_small_ghost",
            tags = { "mywd_small_ghost" },
            root = "true",
            connects = {
                "mywd_small_ghost_2"
            },
        },
        mywd_small_ghost_2 = {
            -- small_ghost 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_SMALL_GHOST_2_TITLE, -- 小惊吓线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SMALL_GHOST_2_DESC,   -- 小惊吓线
            icon = "my_skill_icon",
            pos = { 86, 180 - 40 },
            group = "mywd_small_ghost",
            tags = { "mywd_small_ghost" },
            connects = {
                "mywd_small_ghost_3"
            },
        },
        mywd_small_ghost_3 = {
            -- small_ghost 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_SMALL_GHOST_3_TITLE, -- 小惊吓线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_SMALL_GHOST_3_DESC,   -- 小惊吓线
            icon = "my_skill_icon",
            pos = { 86, 180 - 80 },
            group = "mywd_small_ghost",
            tags = { "mywd_small_ghost" },
        },

        -----------------------------------------------------------------------------

        --祭坛线 3
        mywd_altar_1       = {
            -- altar 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_ALTAR_1_TITLE, -- 祭坛线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ALTAR_1_DESC,   -- 祭坛线
            icon = "my_skill_icon",
            pos = { 136, 180 },
            group = "mywd_altar",
            tags = { "mywd_altar" },
            root = "true",
            connects = {
                "mywd_altar_2"
            },
        },
        mywd_altar_2       = {
            -- altar 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_ALTAR_2_TITLE, -- 祭坛线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ALTAR_2_DESC,   -- 祭坛线
            icon = "my_skill_icon",
            pos = { 136, 180 - 40 },
            group = "mywd_altar",
            tags = { "mywd_altar" },
            connects = {
                "mywd_altar_3"
            },
        },
        mywd_altar_3       = {
            -- altar 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_ALTAR_3_TITLE, -- 祭坛线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_ALTAR_3_DESC,   -- 祭坛线
            icon = "my_skill_icon",
            pos = { 136, 180 - 80 },
            group = "mywd_altar",
            tags = { "mywd_altar" },
        },

        -----------------------------------------------------------------------------

        --花瓣线 3
        mywd_petal_1       = {
            -- petal 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_PETAL_1_TITLE, -- 花瓣线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_PETAL_1_DESC,   -- 花瓣线
            icon = "my_skill_icon",
            pos = { 186, 180 },
            group = "mywd_petal",
            tags = { "mywd_petal" },
            root = "true",
            connects = {
                "mywd_petal_2"
            },
        },
        mywd_petal_2       = {
            -- petal 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_PETAL_2_TITLE, -- 花瓣线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_PETAL_2_DESC,   -- 花瓣线
            icon = "my_skill_icon",
            pos = { 186, 180 - 40 },
            group = "mywd_petal",
            tags = { "mywd_petal" },
            connects = {
                "mywd_petal_3"
            },
        },
        mywd_petal_3       = {
            -- petal 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_PETAL_3_TITLE, -- 花瓣线
            desc = STRINGS.SKILLTREE.MYWD.MYWD_PETAL_3_DESC,   -- 花瓣线
            icon = "my_skill_icon",
            pos = { 186, 180 - 80 },
            group = "mywd_petal",
            tags = { "mywd_petal" }
        },
    }

    return skills
end

--------------------------------------------------------------------------------------------------


local function buildSkillTree(character_name, bg_path, icon_atlas_path, bf_fn)
    local skill_defs = require("prefabs/skilltree_defs")
    local skills = bf_fn(skill_defs.FN)

    -- 注册技能树背景图
    RegisterSkilltreeBGForCharacter(bg_path, character_name)

    -- 注册技能树图标
    local m = {}
    for _, skill_data in pairs(skills) do
        local icon = skill_data.icon
        if icon and not table.contains(m, icon) then
            m[icon] = true
            RegisterSkilltreeIconsAtlas(icon_atlas_path, skill_data.icon .. ".tex")
        end
    end



    skill_defs.CreateSkillTreeFor(character_name, skills)
    skill_defs.SKILLTREE_ORDERS[character_name] = orders
    -- skill_defs.SKILLTREE_METAINFO["wendy"].BACKGROUND_SETTINGS = data.BACKGROUND_SETTINGS
    -- 构建技能树
end
buildSkillTree("wendy", "images/skilltree_bg.xml", "images/mywd_icon.xml", BuildSkillsData)
