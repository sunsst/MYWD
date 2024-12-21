name = "Wendy SkillTree"  -- 名称
description = "温蒂的技能树"  -- 描述
author = "温蒂厨"  -- 作者
version = "0.0.1"  -- 版本
forumthread = ""  -- mod的URL
icon_atlas = "modicon.xml"  -- 模组图标文件的配置文件
icon = "modicon.tex"  -- 模组图标文件
dst_compatible = true  -- 兼容联机版
client_only_mod = false  -- 客户端mod
-- sever_only_mod = true  -- 服务器mod
all_clients_require_mod = true  -- 客户端和服务器端都安装
api_version = 10  -- 10表示联机版mod
priority = 0  -- 模组优先级，优先级越低，越晚载入；同变量时，后载入的mod覆盖前面的mod
sever_filter_tags = {}  -- 服务器标签

-- 模组配置 --
local languages_setting = {
    {description = "中文", data = "Chinese"},
    {description = "English", data = "English"},
}

configuration_options = {
    {
        name = "LAN_SETTING",  -- modmain.lua的调用变量
        label = "语言",  -- 配置名字
        hover = "选择显示的语言",  -- 配置描述
        options = languages_setting,  --配置选项
        default = "Chinese",  -- 默认配置
    }
}



--[[
-- @diagnostic disable: lowercase-global

name = "a我的温蒂"
author = "unknown"
description = "自制温蒂技能树"
version = "0.0.1"
dst_compatible = true
forge_compatible = false
gorge_compatible = false
dont_starve_compatible = false
client_only_mod = false
all_clients_require_mod = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"
forumthread = ""
api_version_dst = 10
priority = 0
mod_dependencies = {}
server_filter_tags = {}
configuration_options = {

}
]]--
