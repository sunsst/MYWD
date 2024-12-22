local function post_fn(self)
    -- 暗影buff期间当召唤阿比时切换至生成状态
    local old_appear_onexit = self.states.appear.onexit
    self.states.appear.onexit = function(inst)
        old_appear_onexit(inst)
        inst.components.mywd_shadowab:ToAppear()
    end
end


AddStategraphPostInit("abigail", post_fn)
