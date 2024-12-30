local CatchButterfly = Class(BehaviourNode, function(self, inst, leader_update_fn, catch_distance, see_distance)
    BehaviourNode._ctor(self, "CatchButterfly")
    self.inst = inst
    self.leader_fn = leader_update_fn
    self.catch_distance = catch_distance
    self.see_distance = see_distance
end)



function CatchButterfly:NewTarget()
    self.butterfly = FindEntity(self.leader_fn(self.inst), self.see_distance, function(inst)
        return not inst.entity:GetParent()
    end, { "butterfly" }, { "INLIMBO" })
end

function CatchButterfly:GetButtferfly()
    if self.butterfly and self.butterfly:IsValid() then
        local e = self.butterfly.entity:GetParent()

        local leader = self.leader_fn(self.inst)
        if (e == nil and self.butterfly:IsNear(leader, self.see_distance)) or e == self.inst or e == leader then
            -- 如果还没抓到且温蒂已离开范围就不抓了
            return self.butterfly
        end
    end
    self.butterfly = nil
    return nil
end

-- function CatchButterfly:DBString()
--     if self:IsCatched() then
--         return string.format("Give butterfly %s", tostring(self.catch_target))
--     else
--         return string.format("Catch butterfly %s", tostring(self.catch_target))
--     end
-- end

function CatchButterfly:DoCatch(butterfly)
    local action = BufferedAction(self.inst, self.leader_fn(self.inst), ACTIONS.MYWD_GIVE_BUTTERFLY, butterfly, nil,
        nil, self.catch_distance)
    self.inst.components.locomotor:PushAction(action, true)
end

function CatchButterfly:DoGive(butterfly)
    local action = BufferedAction(self.inst, butterfly, ACTIONS.MYWD_CATCH_BUTTERFLY, nil, nil, nil,
        self.catch_distance)
    self.inst.components.locomotor:PushAction(action, true)
end

function CatchButterfly:Visit()
    local butterfly = self:GetButtferfly()
    if self.status == READY then
        if not butterfly then
            self:NewTarget()
            butterfly = self:GetButtferfly()
        end

        if butterfly then
            local parent = butterfly.entity:GetParent()

            if parent == self.inst then
                self:DoCatch(butterfly)
            elseif parent == nil then
                self:DoGive(butterfly)
            end
            self.status = RUNNING
        else
            -- 没找到新蝴蝶
            self.status = FAILED
        end
    elseif self.status == RUNNING then
        if butterfly then
            local parent = butterfly.entity:GetParent()

            if parent == self.inst then
                self:DoCatch(butterfly)
            elseif parent == nil then
                self:DoGive(butterfly)
            else
                -- 已经给出去了，抓下一个
                self.status = SUCCESS
                self:NewTarget()
            end
        else
            -- 蝴蝶中途不见了或被别人抓了或已经给温蒂了就视为失败
            self.status = FAILED
        end
    end
end

return CatchButterfly
