--
-- Author: lvgansheng
-- Date: 2015-06-01 16:22:12
-- 一些常用但无法分类的工具方法

LuaUtils = {}

--[[
    查找table中某个值的下标，只在每个值都不一样时有效
    @param arr 需要查找的table
    @param value 需要查找的值
    @return 对应值的key
]]
function LuaUtils.findArrIndexByValue(arr,value)
    local tempArr = arr
    local tempValue = value 
    for i,v in ipairs(tempArr) do
        if v == tempValue then
            return i
        end
    end   
end

function LuaUtils.findItemWithKey(tbl,key)
    for _,v in pairs(tbl) do
        if v and v[key] then
            return v
        end
    end
    return nil
end

--将string转为table1
function LuaUtils.stringToTable(str, isTableList)
    if str=="" or str==nil then
        return {}
    end
    local ret, msg
    if isTableList then
        ret, msg = loadstring(string.format("return {%s}", str))
    else
        ret, msg = loadstring(string.format("return %s", str))
    end
    if not ret then
        print("loadstring error", msg)
        return nil
    end
    return ret()
end

--四舍五入
function LuaUtils.roundOff(num)
    local integer, decimal = math.modf(num)
    if decimal >= 0.5 then
        return integer + 1
    else
        return integer
    end
end

--拼接lua数组表
function LuaUtils.joinArrTab(tab_one, tab_two)
    local new_tab = {}

    for i=1,#tab_one do
        table.insert(new_tab, tab_one[i])
    end

     for i=1,#tab_two do
        table.insert(new_tab, tab_two[i])
    end

    return new_tab
end

