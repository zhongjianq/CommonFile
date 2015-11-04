--
-- Author: thisgf
-- Date: 2015-04-16 14:30:25
-- 设备管理 static class

DeviceManager = class("DeviceManager")

DeviceManager._deviceId = "0"
DeviceManager._deviceName = ""
DeviceManager._platformName = ""

function DeviceManager:init()

	require("SdkLuaMgr")

    DeviceManager._deviceName = SdkLuaMgr:getInstance():getDeviceOs()
    DeviceManager._platformName = device.platform

end

function DeviceManager:getTargetPlatform()
    return cc.Application:getInstance():getTargetPlatform()
end

--[[
    获取设备ID
]]
function DeviceManager:getDeviceId()
    return DeviceManager._deviceId
end

--[[
    获取设备名称
]]
function DeviceManager:getDeviceName()
    return DeviceManager._deviceName
end

-- function DeviceManager:getPlatformName()
--     -- return DeviceManager._platformName
--     return "dev"
-- end
