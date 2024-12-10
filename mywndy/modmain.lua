Assets = {
    Asset("ATLAS", "images/wendy_skilltree_bg.xml"),
    Asset("ATLAS", "images/my_icon.xml"),
}
modimport("languages/chs")

local function buildSkillTree()
    RegisterSkilltreeBGForCharacter("images/wendy_skilltree_bg.xml", "wendy")
    RegisterSkilltreeIconsAtlas("images/my_icon.xml", "my_skill_icon.tex")
    -- 注册技能树背景图

    local skill_defs = require("prefabs/skilltree_defs")
    local data = require("prefabs/skilltree_mywd")(skill_defs.FN)

    skill_defs.CreateSkillTreeFor("wendy", data.SKILLS)
    skill_defs.SKILLTREE_ORDERS["wendy"] = data.ORDERS
    skill_defs.SKILLTREE_METAINFO["wendy"].BACKGROUND_SETTINGS = data.BACKGROUND_SETTINGS
    -- 构建技能树
end
buildSkillTree()

for key, value in pairs(GLOBAL.STRINGS.SKILLTREE.PANELS) do
    print("MYWD_SP: ", key, "-", value)
end
