-- 放置的间隙
local SPACE = 6
-- 放置的起始半径
local RADIUS = SPACE


local function rotate_point(pt, theta)
    return Point(pt.x * math.cos(theta) - pt.z * math.sin(theta),
        pt.y,
        pt.x * math.sin(theta) + pt.z * math.cos(theta))
end

local function put_all_anims(anims, loop)
    local pt = ThePlayer:GetPosition()

    local ents = {}
    local ents_i = 1
    if not anims then return end
    for build, v in pairs(anims) do
        for bank, vv in pairs(v) do
            for i, anim in ipairs(vv) do
                table.insert(ents, MakeAnimTesterAt(build, bank, anim, pt.x, pt.y, pt.z, loop))
            end
        end
    end

    local raduis = RADIUS
    while true do
        local n      = math.floor(2 * math.pi / (math.asin(SPACE / 2 / raduis) * 2))
        local radian = 2 * math.pi / n
        local new_pt = Point(raduis, 0, 0)
        c_announce(string.format("n = %d, radian = %f, raduis = %f", n, radian, raduis))
        for i = 1, n do
            if ents_i > #ents then
                return #ents
            end
            ents[ents_i].Transform:SetPosition(pt.x + new_pt.x, pt.y, pt.z + new_pt.z)

            new_pt = rotate_point(new_pt, radian)
            ents_i = ents_i + 1
        end
        raduis = raduis + SPACE
    end
end



-- MYWD_ANIMS = { ["build"] = { ["bank"] = { "anim" } } }
local function enable()
    TheInput:AddKeyHandler(function(key, down) -- 监听键盘事件
        if down and TheInput:IsKeyDown(KEY_SHIFT) then
            if key == KEY_INSERT then
                local n = put_all_anims(MYWD_ANIMS, true)
                c_announce(string.format("已生成循环动画 %d 个，世界上共 %d 个", n, #AllAnimTesters))
            elseif key == KEY_HOME then
                local n = put_all_anims(MYWD_ANIMS, false)
                c_announce(string.format("已生成不循环动画 %d 个，世界上共 %d 个", n, #AllAnimTesters))
            elseif key == KEY_DELETE then
                ClearAllAnimTester()
                c_announce("已清除所有动画")
            end
        end
    end)
end
-- enable()
