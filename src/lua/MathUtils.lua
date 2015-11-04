--
-- Author: thisgf
-- Date: 2015-03-20 21:00:00
-- 数学工具类

require "ASGeometry"

MathUtils = {}

MathUtils.DEG_BASE = math.pi / 180
MathUtils.RAD_BASE = 180 / math.pi

--[[
    获取两点之间的角度[0, 360)
]]
function MathUtils:getDegWithTwoPoint(a, b)
    local dy = b.y - a.y
    local dx = b.x - a.x

    local rad = math.atan2(dy, dx)
    if rad < 0 then
        rad = rad + math.pi * 2
    end

    return MathUtils:rad2deg(rad)
end

--[[
    获取两点之间的弧度, [-math.pi, math.pi)
]]
function MathUtils:getRadWithTwoPoint(a, b)
    local dy = b.y - a.y
    local dx = b.x - a.x

    return math.atan2(dy, dx)
end

--[[
    获取两点之间的距离
]]
function MathUtils:getDistance(pOne, pTwo)

    local dx = pTwo.x - pOne.x
    local dy = pTwo.y - pOne.y

    return math.sqrt(dx * dx + dy * dy)

end

--[[
    计算线性速度 
    @param currentPos 当前点
    @param targetPos 目标点
    @param velocity 向量速度
    @return Point  
]]
function MathUtils:calcLinearVelocity(currentPos, targetPos, velocity)

    local p = Point:create()
            
    local dx = targetPos.x - currentPos.x
    local dy = targetPos.y - currentPos.y
    
    local rad = math.atan2(dy, dx)
   
    p.x = velocity * math.cos(rad)
    p.y = velocity * math.sin(rad)
    
    return p
end

--[[
    比较两点之间的距离和参数距离 
    @param beginPos
    @param endPos
    @param distance
    @return 大于:1, 等于:0, 小于:-1
]]        
function MathUtils:compareDistance(beginPos, endPos, distance)

    local dy = endPos.y - beginPos.y
    local dx = endPos.x - beginPos.x
    
    local dist = dy * dy + dx * dx
    
    distance = distance * distance

    if dist > distance then
        return 1
    elseif dist == distance then
        return 0
    else
        return -1
    end
end

--[[
    计算当前点到目标点减去所设距离的位置 
    @param beginPos
    @param targetPos
    @param dist
    @return x, y
]]
function MathUtils:calcTargetPosWithDistance(beginPos, targetPos, dist)

    -- local radian = math.atan2(targetPos.y-beginPos.y, targetPos.x-beginPos.x)
    -- local actualPos = Point:create(
    --     targetPos.x-math.cos(radian)*dist, 
    --     targetPos.y-math.sin(radian)*dist
    -- )
    -- return actualPos

    local radian = math.atan2(targetPos.y-beginPos.y, targetPos.x-beginPos.x)
    return targetPos.x-math.cos(radian)*dist, targetPos.y-math.sin(radian)*dist
end

--角度转弧度
function MathUtils:deg2rad(value)
    return value * MathUtils.DEG_BASE
end

--[[
    弧度转角度
]]
function MathUtils:rad2deg(value)
    return value * MathUtils.RAD_BASE
end

--[[
    洗乱数组
]]
function MathUtils:shuffleList(list)
    local len = #list

    for i = 1, len do
        local randomIndex = math.random(1, len)

        list[i], list[randomIndex] = list[randomIndex], list[i]
    end
end

function MathUtils:isNaN(n)
    return n ~= n
end
