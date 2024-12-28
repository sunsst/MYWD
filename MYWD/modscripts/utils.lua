-- 用不到但先留着
-- function GetRawObjectPropsArg(obj, arg_name)
--     return rawget(obj, "_")[arg_name][2]
-- end
-- function ResetObjectPropsArg(obj, arg_name, newvalue)
--     rawget(obj, "_")[arg_name][2] = newvalue
-- end

-- 这个函数帮助你通过名字定位行为树中的一个节点
-- 它的返回值是它的父节点以及它的位置
function SearchNodeInBraintreeWithName(node_name, in_node)
    if not in_node then
        return
    end

    if type(in_node.children) == "table" then
        for i, child_node in ipairs(in_node.children) do
            if child_node.name == node_name then
                return in_node, i
            end
            local getnode, getat = SearchNodeInBraintreeWithName(node_name, child_node)
            if getat then
                return getnode, getat
            end
        end
    end
end
