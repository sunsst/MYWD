-- 在这个文件里梭哈所有的全局变量
-- 只会影响到 "modscripts/**.lua" 和 "modmain.lua"
local IMPORT_GLOBAL = {
    STRINGS = true,
    ACTIONS = true,
    TUNING = true,
    CreateEntity = true,

    ThePlayer = true,
    TheWorld = true,
    TheInput = true,
    Vector3 = true,

    c_announce = true,
    shallowcopy = true,
    net_event = true,

    ANIM_ORIENTATION = true,
    LAYER_BACKGROUND = true,


    KEY_HOME = true,
    KEY_INSERT = true,
    KEY_PAGEUP = true,
    KEY_END = true,

    DEFAULTFONT = true,

    TECH = true,
    GetScrapbookIconAtlas = true,

    TheGenericKV = true,

    Action = true
}

-- 不要直接设置 GLOBAL 会报错
GLOBAL.setmetatable(env, {
    __index = function(_, key)
        if IMPORT_GLOBAL[key] then
            return GLOBAL[key]
        end
    end
})
