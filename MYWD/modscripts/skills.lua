local groups =
{
    { "wdga", { -214, 210 } },
    { "wdgb", { -214 + 40, 210 } },
    { "wdgc", { -214 + 80, 210 } },
    { "wdgd", { -214 + 120, 210 } },
    { "wdge", { -214 + 160, 210 } },
    { "wdgf", { -214 + 200, 210 } },
    { "wdgg", { -214 + 240, 210 } },
    { "wdgh", { -214 + 280, 210 } },
    { "wdgj", { -214 + 320, 210 } },
    { "wdgk", { -214 + 360, 210 } },
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- 绮梦 5
        mywd_wdga_lock_1 = {
            -- 1 1
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_lock_1_DESC, -- 绮梦
            pos = { -214, 180 },
            group = "wdga",
            tags = { "wdga", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                -- return SkillTreeFns.CountTags(prefabname, "torch1", activatedskills) > 2
                return true
            end,
            connects = {
                "mywd_wdga_lock_2",
            },
            defaultfocus = true
        },
        mywd_wdga_lock_2 = {
            -- 1 2
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_lock_2_DESC, -- 绮梦
            pos = { -214 + 40, 180 },
            group = "wdga",
            tags = { "wdga", "lock" },
            lock_open = function(prefabname, activatedskills, readonly)
                -- return SkillTreeFns.CountTags(prefabname, "torch1", activatedskills) > 2
                return true
            end,
            connects = {
                "mywd_wdga_1",
            },
        },
        mywd_wdga_1 = {
            -- 1 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_1_TITLE, -- 绮梦
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_1_DESC,   -- 绮梦
            icon = "my_skill_icon",
            pos = { -214 + 80, 180 },
            group = "wdga",
            tags = { "wdga" },
            connects = {
                "mywd_wdga_2",
            },
        },
        mywd_wdga_2 = {
            -- 1 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_2_TITLE, -- 绮梦
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_2_DESC,   -- 绮梦
            icon = "my_skill_icon",
            pos = { -214 + 120, 180 },
            group = "wdga",
            tags = { "wdga" },
            connects = {
                "mywd_wdga_3",
            },
        },
        mywd_wdga_3 = {
            -- 1 5
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_3_TITLE, -- 绮梦
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGA_3_DESC,   -- 绮梦
            icon = "my_skill_icon",
            pos = { -214 + 160, 180 },
            group = "wdga",
            tags = { "wdga" },
        },

        -----------------------------------------------------------------------------

        --懊悔 5
        mywd_wdgb_lock_1 = {
            -- 2 1
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_lock_1_DESC, -- 懊悔
            pos = { -214, 180 - 60 },
            group = "wdgb",
            tags = { "wdgb", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                -- return SkillTreeFns.CountTags(prefabname, "torch1", activatedskills) > 2
                return true
            end,
            connects = {
                "mywd_wdgb_lock_2",
            },
        },
        mywd_wdgb_lock_2 = {
            -- 2 2
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_lock_2_DESC, -- 懊悔
            pos = { -214 + 40, 180 - 60 },
            group = "wdgb",
            tags = { "wdgb", "lock" },
            lock_open = function(prefabname, activatedskills, readonly)
                -- return SkillTreeFns.CountTags(prefabname, "torch1", activatedskills) > 2
                return true
            end,
            connects = {
                "mywd_wdgb_1",
            },
        },
        mywd_wdgb_1 = {
            -- 2 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_1_TITLE, -- 懊悔
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_1_DESC,   -- 懊悔
            icon = "my_skill_icon",
            pos = { -214 + 80, 180 - 60 },
            group = "wdgb",
            tags = { "wdgb" },
            connects = {
                "mywd_wdgb_2",
            },
        },
        mywd_wdgb_2 = {
            -- 2 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_2_TITLE, -- 懊悔
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_2_DESC,   -- 懊悔
            icon = "my_skill_icon",
            pos = { -214 + 120, 180 - 60 },
            group = "wdgb",
            tags = { "wdgb" },
            connects = {
                "mywd_wdgb_3",
            },
        },
        mywd_wdgb_3 = {
            -- 2 5
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_3_TITLE, -- 懊悔
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGB_3_DESC,   -- 懊悔
            icon = "my_skill_icon",
            pos = { -214 + 160, 180 - 60 },
            group = "wdgb",
            tags = { "wdgb" },
        },

        -----------------------------------------------------------------------------

        --可爱 3
        mywd_wdgc_1 = {
            -- 3 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGC_1_TITLE, -- 可爱
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGC_1_DESC,   -- 可爱
            icon = "my_skill_icon",
            pos = { -214 + 220, 180 },
            group = "wdgc",
            tags = { "wdgc" },
            root = "true",
            connects = {
                "mywd_wdgc_2"
            },
        },
        mywd_wdgc_2 = {
            -- 3 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGC_2_TITLE, -- 可爱
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGC_2_DESC,   -- 可爱
            icon = "my_skill_icon",
            pos = { -214 + 220, 180 - 40 },
            group = "wdgc",
            tags = { "wdgc" },
            connects = {
                "mywd_wdgc_3"
            },
        },
        mywd_wdgc_3 = {
            -- 3 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGC_3_TITLE, -- 可爱
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGC_3_DESC,   -- 可爱
            icon = "my_skill_icon",
            pos = { -214 + 220, 180 - 80 },
            group = "wdgc",
            tags = { "wdgc" },
        },

        -----------------------------------------------------------------------------

        --花篮 1
        mywd_wdgd_1 = {
            -- 4 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGD_1_TITLE, -- 花篮
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGD_1_DESC,   -- 花篮
            icon = "my_skill_icon",
            pos = { -214 + 280, 180 },
            group = "wdgd",
            tags = { "wdgd" },
            root = "true",
        },

        -----------------------------------------------------------------------------

        --亡语 1
        mywd_wdge_2 = {
            -- 5 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGE_2_TITLE, -- 亡语
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGE_2_DESC,   -- 亡语
            icon = "my_skill_icon",
            pos = { -214 + 280, 180 - 60 },
            group = "wdge",
            tags = { "wdge" },
            root = "true",
        },

        -----------------------------------------------------------------------------

        --灵药 3
        mywd_wdgf_1 = {
            -- 6 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGF_1_TITLE, -- 灵药
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGF_1_DESC,   -- 灵药
            icon = "my_skill_icon",
            pos = { -214 + 340, 180 },
            group = "wdgf",
            tags = { "wdgf" },
            root = "true",
            connects = {
                "mywd_wdgf_2"
            },
        },
        mywd_wdgf_2 = {
            -- 6 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGF_2_TITLE, -- 灵药
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGF_2_DESC,   -- 灵药
            icon = "my_skill_icon",
            pos = { -214 + 340, 180 - 40 },
            group = "wdgf",
            tags = { "wdgf" },
            connects = {
                "mywd_wdgf_3"
            },
        },
        mywd_wdgf_3 = {
            -- 6 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGF_3_TITLE, -- 灵药
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGF_3_DESC,   -- 灵药
            icon = "my_skill_icon",
            pos = { -214 + 340, 180 - 80 },
            group = "wdgf",
            tags = { "wdgf" },
        },

        -----------------------------------------------------------------------------

        --骨灰盒 3
        mywd_wdgg_1 = {
            -- 7 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGG_1_TITLE, -- 骨灰盒
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGG_1_DESC,   -- 骨灰盒
            icon = "my_skill_icon",
            pos = { -214 + 400, 180 },
            group = "wdgg",
            tags = { "wdgg" },
            root = "true",
            connects = {
                "mywd_wdgg_2"
            },
        },
        mywd_wdgg_2 = {
            -- 7 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGG_2_TITLE, -- 骨灰盒
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGG_2_DESC,   -- 骨灰盒
            icon = "my_skill_icon",
            pos = { -214 + 400, 180 - 40 },
            group = "wdgg",
            tags = { "wdgg" },
            connects = {
                "mywd_wdgg_3"
            },
        },
        mywd_wdgg_3 = {
            -- 7 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGG_3_TITLE, -- 骨灰盒
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGG_3_DESC,   -- 骨灰盒
            icon = "my_skill_icon",
            pos = { -214 + 400, 180 - 80 },
            group = "wdgg",
            tags = { "wdgg" },
        },

        -----------------------------------------------------------------------------

        --小惊吓 3
        mywd_wdgh_1 = {
            -- 8 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGH_1_TITLE, -- 小惊吓
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGH_1_DESC,   -- 小惊吓
            icon = "my_skill_icon",
            pos = { -214, 180 - 140 },
            group = "wdgh",
            tags = { "wdgh" },
            root = "true",
            connects = {
                "mywd_wdgh_2"
            },
        },
        mywd_wdgh_2 = {
            -- 8 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGH_2_TITLE, -- 小惊吓
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGH_2_DESC,   -- 小惊吓
            icon = "my_skill_icon",
            pos = { -214 + 40, 180 - 140 },
            group = "wdgh",
            tags = { "wdgh" },
            connects = {
                "mywd_wdgh_3"
            },
        },
        mywd_wdgh_3 = {
            -- 8 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGH_3_TITLE, -- 小惊吓
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGH_3_DESC,   -- 小惊吓
            icon = "my_skill_icon",
            pos = { -214 + 80, 180 - 140 },
            group = "wdgh",
            tags = { "wdgh" },
        },

        -----------------------------------------------------------------------------

        --墓碑 3
        mywd_wdgj_1 = {
            -- 9 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGJ_1_TITLE, -- 墓碑
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGJ_1_DESC,   -- 墓碑
            icon = "my_skill_icon",
            pos = { -214 + 140, 180 - 140 },
            group = "wdgj",
            tags = { "wdgj" },
            root = "true",
            connects = {
                "mywd_wdgj_2"
            },
        },
        mywd_wdgj_2 = {
            -- 9 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGJ_2_TITLE, -- 墓碑
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGJ_2_DESC,   -- 墓碑
            icon = "my_skill_icon",
            pos = { -214 + 180, 180 - 140 },
            group = "wdgj",
            tags = { "wdgj" },
            connects = {
                "mywd_wdgj_3"
            },
        },
        mywd_wdgj_3 = {
            -- 9 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGJ_3_TITLE, -- 墓碑
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGJ_3_DESC,   -- 墓碑
            icon = "my_skill_icon",
            pos = { -214 + 220, 180 - 140 },
            group = "wdgj",
            tags = { "wdgj" },
        },

        -----------------------------------------------------------------------------

        --虚影 3
        mywd_wdgk_1 = {
            -- 10 1
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_1_TITLE, -- 虚影
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_1_DESC,   -- 虚影
            icon = "my_skill_icon",
            pos = { -214 + 280, 180 - 140 },
            group = "wdgk",
            tags = { "wdgk" },
            root = "true",
            connects = {
                "mywd_wdgk_2"
            },
        },
        mywd_wdgk_2 = {
            -- 10 2
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_2_TITLE, -- 虚影
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_2_DESC,   -- 虚影
            icon = "my_skill_icon",
            pos = { -214 + 320, 180 - 140 },
            group = "wdgk",
            tags = { "wdgk" },
            connects = {
                "mywd_wdgk_3"
            },
        },
        mywd_wdgk_3 = {
            -- 10 3
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_3_TITLE, -- 虚影
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_3_DESC,   -- 虚影
            icon = "my_skill_icon",
            pos = { -214 + 360, 180 - 140 },
            group = "wdgk",
            tags = { "wdgk" },
            connects = {
                "mywd_wdgk_4"
            },
        },
        mywd_wdgk_4 = {
            -- 10 4
            title = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_4_TITLE, -- 虚影
            desc = STRINGS.SKILLTREE.MYWD.MYWD_WDGK_4_DESC,   -- 虚影
            icon = "my_skill_icon",
            pos = { -214 + 400, 180 - 140 },
            group = "wdgk",
            tags = { "wdgk" },
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
    skill_defs.SKILLTREE_ORDERS[character_name] = groups
    -- skill_defs.SKILLTREE_METAINFO["wendy"].BACKGROUND_SETTINGS = data.BACKGROUND_SETTINGS
    -- 构建技能树
end
buildSkillTree("wendy", "images/skilltree_bg.xml", "images/mywd_icon.xml", BuildSkillsData)
