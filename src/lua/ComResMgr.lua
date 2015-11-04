--
-- Author: lvgansheng
-- Date: 2015-05-26 20:37:34
-- 资源管理

require "TextureManager"

ComResMgr = class("ComResMgr")

local _instance = nil
local _allowInstance = false

local res_path_dic = nil

function ComResMgr:ctor()
    if not _allowInstance then
        error("ComResMgr is a singleton class,please call getInstance method")
    end

    res_path_dic = {}
end

function ComResMgr:getInstance()
    if _instance == nil then
        _allowInstance = true
        _instance = ComResMgr.new()
        _allowInstance = false
    end
    return _instance
end

function ComResMgr:loadRes(plist_path)
    TextureManager:addUISpriteFrames(plist_path)
    -- if plist_path == nil or plist_path == "" then
    --     return 
    -- end

    -- if res_path_dic[plist_path] then --已经加载过
    --     return
    -- end

    -- cc.SpriteFrameCache:getInstance():addSpriteFrames(plist_path)
    -- res_path_dic[plist_path] = true
end

