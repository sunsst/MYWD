-- 根据变量名获取函数上值
-- f 函数
-- var_name 上值的变量名
-- @ret1 上值的值，如果没找到返回nil
-- @ret2 上值的序号，如果没找到返回nil
function GetUpValue(f, var_name)
    local i = 0
    while true do
        i = i + 1
        local name, v = debug.getupvalue(f, i)
        if name == var_name then
            return v, i
        elseif name == nil then
            return nil, nil
        end
    end
end

-- 根据变量名设置函数上值的值
-- f 函数
-- var_name 上值的变量名
-- var_value 设置的值
-- @ret1 如果成功返回变量名，没有则返回nil
function SetUpValue(f, var_name, var_value)
    local i = 0
    while true do
        i = i + 1
        local name = debug.getupvalue(f, i)
        if name == var_name then
            debug.setupvalue(f, i, var_value)
            return name
        elseif name == nil then
            return nil
        end
    end
end

-- 根据变量名获取函数上值
-- f 函数
-- @ret1 所有上值的名字到值的表
function GetAllUpValue(f)
    local i = 0
    local args = {}
    while true do
        i = i + 1
        local name, v = debug.getupvalue(f, i)
        if name then
            args[name] = v
        elseif name == nil then
            return args
        end
    end
end

-- 用不到但先留着
-- function GetRawObjectPropsArg(obj, arg_name)
--     return rawget(obj, "_")[arg_name][2]
-- end
-- function ResetObjectPropsArg(obj, arg_name, newvalue)
--     rawget(obj, "_")[arg_name][2] = newvalue
-- end

-- 这个函数帮助你通过名字定位行为树中的一个节点，它的返回值是它的父节点以及它的位置
-- 不好用，先留着
-- function SearchNodeInBraintreeWithName(node_name, in_node)
--     if not in_node then
--         return
--     end

--     if type(in_node.children) == "table" then
--         for i, child_node in ipairs(in_node.children) do
--             if child_node.name == node_name then
--                 return in_node, i
--             end
--             local getnode, getat = SearchNodeInBraintreeWithName(node_name, child_node)
--             if getat then
--                 return getnode, getat
--             end
--         end
--     end
-- end
