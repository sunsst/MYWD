local FollowText = require "widgets/followtext"

function AddText(target, text, off_y, font, size, off_x)
    size = size or 18
    font = font or GLOBAL.DEFAULTFONT
    off_y = off_y or -20
    off_x = off_x or 0

    local inst = FollowText(font, size, text)
    inst:SetScreenOffset(off_x, off_y)
    inst:SetTarget(target)

    return inst
end
