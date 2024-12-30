-- 修改状态栏的药剂图标
AddClassPostConstruct("widgets/pethealthbadge", function(self)
    self.default_symbol_build = "mywd_status_abigail"
end)
