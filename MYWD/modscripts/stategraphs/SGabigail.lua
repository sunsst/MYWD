local function post_fn(self)
    -- 暗影buff期间当召唤阿比时切换至生成状态
    local old_appear_onexit = self.states.appear.onexit
    self.states.appear.onexit = function(inst)
        old_appear_onexit(inst)
        inst.components.mywd_shadowab:ToAppear()
    end


    -- 暗影buff期间当召唤阿比时停止时运动
    local old_walk_start_onenter = self.states.walk_start.onenter
    self.states.walk_start.onenter = function(inst)
        if inst.components.mywd_shadowab:IsCantMove() then
            c_announce("状态机禁止慢跑")
            inst.sg:GoToState("idle")
            inst.components.locomotor:Stop()
        else
            old_walk_start_onenter(inst)
        end
    end
    local old_run_start_onenter = self.states.run_start.onenter
    self.states.run_start.onenter = function(inst)
        if inst.components.mywd_shadowab:IsCantMove() then
            c_announce("状态机禁止快跑")
            inst.sg:GoToState("idle")
            inst.components.locomotor:Stop()
        else
            old_run_start_onenter(inst)
        end
    end
end


AddStategraphPostInit("abigail", post_fn)
