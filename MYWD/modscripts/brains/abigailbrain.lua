local function post_fn(self)
    -- 让阿比盖尔满足条件时不要移动
    local shadow_abigail_node = ConditionNode(function() return self.inst.components.mywd_shadowab:IsCantMove() end,
        "Shdaow Abigail")
    table.insert(self.bt.root.children, 1, shadow_abigail_node)
end

AddBrainPostInit("abigailbrain", post_fn)
