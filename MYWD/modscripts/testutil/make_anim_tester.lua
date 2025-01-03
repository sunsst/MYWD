-- 是个二维数组，第二项放了实体和文字
AllAnimTesters = {}

function MakeAnimTester(build, bank, anim, loop)
    loop = (loop == nil and true) or loop

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim, loop)

    local t = AddText(inst, build .. ":" .. bank .. "." .. anim, -15, nil, 22)

    table.insert(AllAnimTesters, {
        ent = inst,
        text = t
    })
    return inst
end

function MakeAnimTesterAt(build, bank, anim, x, y, z, loop)
    local inst = MakeAnimTester(build, bank, anim, loop)
    inst.Transform:SetPosition(x, y, z)
    return inst
end

function MakeAnimTesterAtEntity(build, bank, anim, target, loop)
    local inst = MakeAnimTester(build, bank, anim, loop)
    inst.Transform:SetPosition(target.Transform:GetWorldPosition())
    return inst
end

function ClearAllAnimTester()
    for _, tester in ipairs(AllAnimTesters) do
        tester.ent:Remove()
        tester.text.inst:Remove()
    end
    AllAnimTesters = {}
end
