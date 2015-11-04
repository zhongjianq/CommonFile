--
-- Author: thisgf
-- Date: 2014-06-13 19:17:59
-- 文件工具类

FileUtils = {}

--[[
    读取配置文件
    @param fileName 文件名
    @return 读取的文件
]]
function FileUtils.readConfigFile(fileName)

    local dataStr = Bridge:readConfigData(fileName)
    return dataStr

end

--把文件中的每行字符串 插入一个表中
function FileUtils.readLineInTbl(fileName)

    local dataStr = Global:getAssetFileData(fileName, "r")
    return Utils.split(dataStr,"\n")
end
