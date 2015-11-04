--
-- Author: thisgf
-- Date: 2015-04-13 14:13:34
-- 网络管理器 static class

require "proto_common"
require "CommonBus"
require "P10"
require "P100"
require "P103"
require "P11"

NetworkManager = class("NetworkManager")

NetworkManager.DELAY_WARING_BL = {10103}

NetworkManager._lastPid = 0
NetworkManager._lastProto = nil
NetworkManager._isShowProtoLog = false

NetworkManager._isDelay = false

NetworkManager._status = 0

function NetworkManager:init()

    Bridge:registerProtoFuncName("onReceiveProto")
    Bridge:addEvent("NetworkEvent.UPDATE_STATUS", "onUpdateNetworkStatus(int)")
end

function onReceiveProto(protoId, protoContent)

    TimerManager.removeTimer(NetworkManager._onCountTime)
    NetworkManager._isDelay = false

    if NetworkManager._isShowProtoLog then
        local prtStr = string.format("网络调试>> 收到协议 " .. protoId)
        print(prtStr)
        CommonBus:dispatchEvent(GmEvent.ADD_LOG,prtStr)
    end
    local className = string.format("U%d", protoId)

    local clazz = _G[className]
    if not clazz then
        print("收到协议", protoId, "但是没有对应的类")
        return
    end

    local instance = clazz:create()
    instance:unpack(protoContent)

    CommonBus:dispatchEvent(
        NetworkManager:_getProtoName(protoId), 
        instance
    )

end

function onUpdateNetworkStatus(status)

    -- print("============update network status", status)
    NetworkManager._status = status
    CommonBus:dispatchEvent(NetworkEvent.UPDATE_STATUS_LUA, status)
    -- if status == NetworkStatus.CONNECTED then
    --     CommonBus:dispatchEvent(NetworkEvent.RSP_CONNECTED)
    --     -- NetworkManager:sendLastProto()
    -- elseif status == NetworkStatus.CONNECT_LOST then
    --     CommonBus:dispatchEvent(NetworkEvent.RSP_CONNECT_LOST)
    -- end

end

function NetworkManager:_onCountTime()
    NetworkManager._isDelay = true
end

function NetworkManager:_getProtoName(protoId)
    return string.format("proto_%d", protoId)
end

--[[
    添加协议监听
]]
function NetworkManager:addProtoListener(protoId, listener, target)
    CommonBus:addEvent(
        NetworkManager:_getProtoName(protoId), 
        listener, 
        target
    )
end

--[[
    移除协议监听
]]
function NetworkManager:removeProtoListener(protoId, listener)
    CommonBus:removeEvent(
        NetworkManager:_getProtoName(protoId), 
        listener
    )
end

function NetworkManager:connect(ip, port)
    if NetworkManager._status == NetworkStatus.CONNECTED then
        return
    end

    NetworkManager.ip = ip or GameConfig:getIp()
    NetworkManager.port = port or GameConfig:getPort() 
    -- print("要连接的ip=",ip,port)
    Bridge:connectServer(NetworkManager.ip, NetworkManager.port)
end

--将ip跟端口重置回中央服
function NetworkManager:resetToCenterSrv()
    NetworkManager.ip = GameConfig:getIp()
    NetworkManager.port = GameConfig:getPort() 
end

--主动断掉网络
function NetworkManager:sysAutoClose()
    CommonBus:dispatchEvent(NetworkEvent.SYS_AUTO_CLOSE)
    NetworkManager:close()
end

function NetworkManager:close()
     Bridge:closeConnect()
end

--[[
    发送协议
]]
function NetworkManager:sendProto(protoId, protoData)
    NetworkManager._lastPid = protoId
    NetworkManager._lastProto = protoData

    if NetworkManager._status ~= NetworkStatus.CONNECTED then
        NetworkManager:connect(NetworkManager.ip, NetworkManager.port)
        return
    end

    TimerManager.addTimer(5000, NetworkManager._onCountTime, false)

    if NetworkManager._isDelay and 
        not table.indexof(NetworkManager.DELAY_WARING_BL, protoId) then
        Alert:showFaile(language.network.DELAY)
    end

    local ba = protoData:pack()
    Bridge:sendProto(protoId, ba:getLen(), ba:getBytes())

    if NetworkManager._isShowProtoLog then
        local prtStr = string.format("网络调试>> 发送协议" .. protoId)
        print(prtStr)
        CommonBus:dispatchEvent(GmEvent.ADD_LOG,prtStr)
    end
end

function NetworkManager:setVisibleProtoLog(b)
    NetworkManager._isShowProtoLog = b
end

function NetworkManager:sendLastProto()

    if not NetworkManager._lastProto then
        return
    end
    local ba = NetworkManager._lastProto:pack()
    NetworkManager._lastProto = nil
    -- print("网络调试>> 发送协议", NetworkManager._lastPid)
    Bridge:sendProto(NetworkManager._lastPid, ba:getLen(), ba:getBytes())

end

function NetworkManager:status()
    return NetworkManager._status
end

