local params = require("containers").params
params.elixir_container =
{
    widget =
    {
        slotpos        = {},
        slotbg         = {},
        animbank       = "ui_elixir_container_3x3",
        animbuild      = "ui_elixir_container_3x3",
        pos            = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

local elixir_container_bg = { image = "elixir_slot.tex", atlas = resolvefilepath("images/hud2.xml") }

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.elixir_container.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
        table.insert(params.elixir_container.widget.slotbg, elixir_container_bg)
    end
end

function params.elixir_container.itemtestfn(container, item, slot)
    -- Battlesongs.
    return item:HasTag("ghostlyelixir")
end
