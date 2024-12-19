local function put_all_anims(build, bank, anims, loop, padding)
    padding = padding or 4
    loop = loop

    local target = ThePlayer
    if not target or not target:IsValid() or type(anims) ~= "table" then
        c_announce("放不出来")
    end

    print(target)
    local x, y, z = target.Transform:GetWorldPosition()
    x = x + 2
    z = z + 2


    for i, anim in ipairs(anims) do
        local ii = i - 1
        local inst = MakeAnimTesterAt(build, bank, anim, x + (ii % 5) * padding, y, math.floor(ii / 5) * padding + z,
            loop)
        -- c_announce((x + (ii % 5) * padding) .. "  |  " .. y .. "  |  " .. (math.floor(ii / 5) * padding + z))

        if target then
            c_announce(string.format("%s %s.zip",
                (inst.AnimState:GetBuild() == build and inst.AnimState:IsCurrentAnimation(anim)) and
                "√" or "×", build))
            target = nil
        end
    end
end

-- 放置间隙
local padding = 6
-- 动画是否要循环
local loop = true
-- 动画文件名
local build_name = "mywd_abigail"
-- 动画分组/实体
local bank = "yc"
-- 动画名
local anims = {
    "idle",
    "run_start",
    "run",
    "run_stop",
    "angry",
    "appear",
    "dissipate",
    "hit",
    "shy",
    "attack_loop",
    "attack_pre",
    "attack_pst",
    "dance",
    "flower_change",
    "idle_custom",
    "idlexxx",
}

local function enable()
    TheInput:AddKeyHandler(function(key, down) -- 监听键盘事件
        if down then
            if key == KEY_INSERT then
                put_all_anims(build_name, bank, anims, loop, padding)
            elseif key == KEY_HOME then
                put_all_anims(build_name, bank, anims, false, padding)
            elseif key == KEY_PAGEUP then
                put_all_anims(build_name, bank, { anims[1] }, false, padding)
            elseif key == KEY_END then
                for _, e in ipairs(AllAnimTesters) do
                    e.ent:Remove()
                    e.text.inst:Remove()
                end
                AllAnimTesters = {}
                c_announce("清理完成 " .. #AllAnimTesters)
            end
        end
    end)
end
enable()
