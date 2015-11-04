Utils = Utils or {}
Utils.getTblLen = function(tableValue)
  local tableLength = 0
  
  for k, v in pairs(tableValue) do
    tableLength = tableLength + 1
  end
  
  return tableLength
end

--寻找数组中某个值的下标，仅在数组中每个值都不一样时有效
Utils.findIdxByValue = function(arr,value)
    local tempArr = arr
    local tempValue = value 
    for i,v in ipairs(tempArr) do
        if v == tempValue then
            return i
        end
    end   
end



--[[
	根据分隔符分割字符串，返回分割后的table
--]]
Utils.split = function(s, delim)
  assert (type (delim) == "string" and string.len (delim) > 0, "bad delimiter")
  local start = 1
  local t = {}  -- results table

  -- find each instance of a string followed by the delimiter
  while true do
    local pos = string.find(s, delim, start, true) -- plain find
    if not pos then
      break
    end

    table.insert (t, string.sub (s, start, pos - 1))
    start = pos + string.len (delim)
  end -- while

  -- insert final one (after last delimiter)
  table.insert (t, string.sub (s, start))
  return t
end


---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss
Utils.getTimeByDate = function(r)
    local a = Utils.split(r, " ")
    local b = Utils.split(a[1], "-")
    local c = Utils.split(a[2], ":")
    local t = os.time({year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]})
    return t
end

--分别把每个字(包括中英)放进一个表里面
Utils.separate = function(txt)
  local str=txt
    local tblStr = {}
    local i = 1
    while i <= #str  do
       c = str:sub(i,i)
       ord = c:byte()
       if ord > 128 then
          table.insert(tblStr,str:sub(i,i+2))
          i = i+3
       else
          table.insert(tblStr,c)
          i=i+1
       end
    end
    return tblStr
end

--[[
合并字符串
  @param list 目标表
  @param delimiter 分隔符
--]]
Utils.Join = function(delimiter, list)
  local len = table.getn(list)
  if len == 0 then 
    return "" 
  end
  local string = list[1]
  for i = 2, len do 
    string = string .. delimiter .. list[i] 
  end
  return string
end

--字符转颜色 00ff00 转 cc.c3b
Utils.str2Color = function(str)
  str = string.gsub(str,"#","")
  return cc.c3b(tonumber(string.sub(str,1,2),16),
                 tonumber(string.sub(str,3,4),16),
                 tonumber(string.sub(str,5,6),16))
end

--[[
@param sec 秒
--]]
function Utils.sec2TimeStr(sec)
    local my_sec = sec 
    local temp_hours = 0
    local temp_mils = 0
    local temp_secs = 0

    local function formatTime(num)
        if num<10 then
            return "0"..num
        else
            return num
        end
    end

    temp_mils = math.floor(my_sec/60)
    temp_secs = my_sec%60
    
    if temp_mils>59 then
        temp_hours = math.floor(temp_mils/60)
        temp_mils = temp_mils%60
    end

    local time_str = nil
    if temp_hours>0 then
        time_str = formatTime(temp_hours)..":"..formatTime(temp_mils)..":"..formatTime(temp_secs)
    else
        time_str = formatTime(temp_mils)..":"..formatTime(temp_secs)
    end
    return time_str
end

--获取中文 倒计时时间 --样式2
function Utils.getChCoutStringTime(sec)
  local function formatTime(num)
      if num<10 then
          return "0"..num
      else
          return num
      end
  end

    local my_sec = sec 
    local temp_days = 0
    local temp_hours = 0
    local temp_mils = 0
    local temp_secs = 0

    temp_mils = math.floor(my_sec/60)
    temp_secs = my_sec%60
    
    if temp_mils>59 then
        temp_hours = math.floor(temp_mils/60)
        temp_mils = temp_mils%60
    end

    if temp_hours > 23 then
        temp_days = math.floor(temp_hours/24)
        temp_hours = temp_hours%24
    end

    local time_str = nil
    if temp_days > 0 then
        time_str = temp_days.."天"..formatTime(temp_hours).."小时"..formatTime(temp_mils).."分"
    elseif temp_hours>0 then
        time_str = formatTime(temp_hours).."小时"..formatTime(temp_mils).."分"
    elseif temp_mils >0 then
        time_str = temp_mils.."分"
    else
        time_str = temp_secs.."秒"
    end
    return time_str
end

--调整一行的坐标
function Utils.adjustPosX(tbl,baseX,gap,isCenter,isTurn)
    if tbl and #tbl > 0 and tbl[1] then
        local gap = gap or 0
        local anchorPoint = tbl[1]:getAnchorPoint()
        local baseY = tbl[1]:getPositionY()
        local total = 0
        if isTurn then
            local len = #tbl
            for i=1,len do
                local v = tbl[len - (i-1)]
                v:setAnchorPoint(cc.p(1,anchorPoint.y))
                v:setPosition(cc.p(baseX,baseY))
                baseX = baseX - v:getContentSize().width - gap
                total = total + v:getContentSize().width + gap
            end
        else
            for i,v in ipairs(tbl) do
                v:setAnchorPoint(cc.p(0,anchorPoint.y))
                v:setPosition(cc.p(baseX,baseY))
                baseX = baseX + v:getContentSize().width + gap
                total = total + v:getContentSize().width + gap
            end
        end

        if isCenter then
            if total <= tbl[1]:getParent():getContentSize().width then
                local left = (tbl[1]:getParent():getContentSize().width - total) / 2
                for i,v in ipairs(tbl) do
                    if v:isVisible() then
                      v:setPositionX(left)
                      left = left + v:getContentSize().width + gap
                    end
                end
            else
                local left = (tbl[1]:getParent():getContentSize().width - total) / 2
                for i,v in ipairs(tbl) do
                    if v:isVisible() then
                      v:setPositionX(left)
                      left = left + v:getContentSize().width + gap
                    end
                end
            end
        end
    end
end

--调整一行的坐标 (直接传控件名)
Utils.adjustWidgetPosX = function(rootWidget,tbl,baseX,gap,isCenter,isTurn)
    local ret = {}
    for _,widgetName in ipairs(tbl) do
        table.insert(ret,ccui.Helper:seekWidgetByName(rootWidget,widgetName))
    end
    Utils.adjustPosX(ret,baseX,gap,isCenter,isTurn)
end

--根据字符计算宽度(估算)
function Utils.coutStrWidth(str)
    local width = 0
    local i = 1
    while i <= #str  do
       c = str:sub(i,i)
       ord = c:byte()
       if ord > 128 then
          width = width + 24
          i = i+3
       else
          width = width + 14
          i=i+1
       end
    end
    return width
end

--去除字符串两边空格
function Utils.trim(s) return (string.gsub(s, "^%s*(.-)%s*$", "%1")) end

--合并表
Utils.containTab = function(tab1,tab2)
    local ret = {}
    if tab1 and tab2 then
        for k,v in pairs(tab1) do
            table.insert(ret,v)
        end
        for k,v in pairs(tab2) do
            table.insert(ret,v)
        end
    end
    return ret
end

--获取中文 倒计时时间
function Utils.getChCoutStrTime(second,limit)
    local ret = ""
    limit = limit or 60
    if second < limit then
        ret = "刚刚"
    elseif second < 60 * 60 then
        ret = math.floor( second / 60 ) .. "分钟前"
    elseif second < 60 * 60 * 24 then
        ret = math.floor( second / 3600 ) .. "小时前"
    else
        ret = math.min(1, math.floor( second / ( 3600 * 24 ) )) .. "天前"
    end
    return ret
end

function Utils.makeStrSize(str,lineWidth)
    local width = 1
    local i = 1
    while i <= #str  do
       c = str:sub(i,i)
       ord = c:byte()
       if ord > 128 then
          width = width + 24
          i = i+3
       else
          width = width + 14
          i=i+1
       end
    end
    local height = math.max(1, math.ceil(width / lineWidth)) * 24
    return cc.size(lineWidth,height),height
end

--[[
     获取ScrollView滚动比例
     @return percent 0-100
]]
function Utils.getScrollViewPercent(scrollView)
  local function isNaN(x)
    return x ~= x
  end

  local svSize = scrollView:getContentSize()

  local innerSize = scrollView:getInnerContainerSize()

  local innerPos = cc.p(scrollView:getInnerContainer():getPosition())

  local direction = scrollView:getDirection()

  local hp = math.abs(innerPos.x) / (innerSize.width - svSize.width)

  if hp > 1 then
    hp = 1
  elseif hp < 0 then
    hp = 0
  elseif isNaN(hp) then
    hp = 0
  end

  local vp = math.abs(innerPos.y) / (innerSize.height - svSize.height)

  if vp > 1 then
    vp = 1
  elseif vp < 0 then
    vp = 0
  elseif isNaN(vp) then
    vp = 0
  end

  hp = hp * 100
  vp = vp * 100

  if direction == ccui.ScrollViewDir.none then
    return 0
  elseif direction == ccui.ScrollViewDir.vertical then
    return vp
  elseif direction == ccui.ScrollViewDir.horizontal then
    return hp
  else
    return hp, vp
  end
end

--将阿拉伯数字转为中文数字
function Utils.converNumToChinese(num)
    if num == 0 then
        return language.digit[1]
    elseif num ==1 then
         return language.digit[2]
    elseif num ==2 then
         return language.digit[3]
    elseif num ==3 then
         return language.digit[41]
    elseif num ==4 then
         return language.digit[5]
    elseif num ==5 then
         return language.digit[6]
    elseif num ==6 then
         return language.digit[7]
    elseif num ==7 then
         return language.digit[8]
    elseif num ==8 then
         return language.digit[9]
    elseif num ==9 then
         return language.digit[10]
    end
end

--将金钱的显示转换为简短方式,例如100000转为10w
function Utils.converMoneyToShortDesc(money_num)
  if money_num<10000000 then
    return money_num
  end
  return math.floor(money_num/1000).."K"
end

--将时间戳转换为字符串描述
--desc_type = 1 表示X月X日10:00这种格式,不需要显示年
function Utils.unixTime2DateStr(target_unix_time,desc_type)
    if desc_type==nil then
        desc_type = 1
    end

    local target_time_tab =  os.date("*t", target_unix_time)
    local date_str = ""
    local hour_desc = target_time_tab.hour
    local min_desc = target_time_tab.min
    
    if target_time_tab.hour<10 then
        hour_desc = "0"..target_time_tab.hour
    end

    if target_time_tab.min<10 then
        min_desc = "0"..target_time_tab.min
    end

    if desc_type==1 then
        date_str = string.format("%d月%d日%s:%s",target_time_tab.month,target_time_tab.day ,hour_desc ,min_desc  )
    end

    return date_str
end

--设置数量文本，如果数量不够文本显示红色(可用于道具，金钱的数量文本...)
function Utils.setNumText(text, real_num, need_num, style)
    style = style or 1
    if style == 1 then
      text:setString(real_num.."/"..need_num)
    elseif style == 2 then
      text:setString(need_num)
    end
    if real_num >= need_num then
      text:setColor(cc.c3b(255, 255, 255))
    else
      text:setColor(cc.c3b(255, 0, 0))
    end
end

--设置图片资产类型
function Utils.setAssetImg(img, assetType)
  if AssetType.gold == assetType then
    img:loadTexture("res/gold_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.binded_gold == assetType then
    img:loadTexture("res/binded_gold_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.copper == assetType then
    img:loadTexture("res/copper_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.binded_copper == assetType then
    img:loadTexture("res/binded_copper_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.online_point == assetType then -- 在线竞技积分
    img:loadTexture("res/online_point_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.offline_point == assetType then
    img:loadTexture("res/offline_point_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.chivalrous == assetType then
    img:loadTexture("res/chivalrous_icon.png", ccui.TextureResType.plistType)
  elseif AssetType.guild_donate == assetType then
    img:loadTexture("res/guild_icon.png", ccui.TextureResType.plistType)
  end
end

function Utils.getAssetName(assetType)
  if AssetType.gold == assetType then
    return language.asset.gold
  elseif AssetType.binded_gold == assetType then
    return language.asset.binded_gold
  elseif AssetType.copper == assetType then
    return language.asset.copper
  elseif AssetType.binded_copper == assetType then
    return language.asset.binded_copper
  elseif AssetType.online_point == assetType then -- 在线竞技积分
   return language.asset.online_point
  elseif AssetType.offline_point == assetType then
    return language.asset.offline_point
  elseif AssetType.chivalrous == assetType then
    return language.asset.chivalrous
  elseif AssetType.guild_donate == assetType then
    return language.asset.guild_donate
  end
end