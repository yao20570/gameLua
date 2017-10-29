local IosAppUtils = {}

function IosAppUtils:initSDKInfo(info)
    local args = info
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"initSDKInfo",args)
    if not ok then
    else
        print("========initSDKInfo=========")
    end
end

function IosAppUtils:isInitSDKFinish()
    --8095 【iOS】进入游戏后使用SDK或者游戏设置的切换账号功能后，游戏直接闪退  当时的线上版本还没有加入isInitSDKFinish函数,直接返回true
    -- local args = nil
    -- local luaoc = require "luaoc"
    -- local className = "LuaObjectCBridge"
    -- local ok,ret  = luaoc.callStaticMethod(className,"isInitSDKFinish",args)
    -- if not ok then
    -- else
    --     print("========isInitSDKFinish=========")
    -- end
    -- if ret == 1 then
    --     return true
    -- else
    --     return false
    -- end

    return true
end

function IosAppUtils:showLoginView()
    local args = nil
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"showLoginView",args)
    if not ok then
    else
        print("========showLoginView=========")
    end
end

function IosAppUtils:showReLogionView()
    local args = nil
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"showLoginView",args)
    if not ok then
    else
        print("========showReLogionView=========")
    end
end

function IosAppUtils:showChargeView(info)
    local args = info
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"showChargeView",args)
    if not ok then
        print("========showChargeView fail=========")
    else
        print("========showChargeView=========")
    end
end

function IosAppUtils:sdkLogOut()
    local args = nil
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"sdkLogOut",args)
    if not ok then
    else
        print("========sdkLogOut=========")
    end
end

function IosAppUtils:getPhoneInfo()
    local phoneInfo = ""
    local args = nil
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"getPhoneInfo",args)
    if not ok then
    else
        print("========getPhoneInfo=========")
        phoneInfo = ret
    end
    return phoneInfo
end


function IosAppUtils:showChargeView(info)
    local args = info
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"showChargeView",args)
    if not ok then
    else
        print("========showChargeView=========")
    end
end


function IosAppUtils:initSDKExtendData(infoTable)
    local args = infoTable
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"initSDKExtendData",args)
    if not ok then
    else
        print("========initSDKExtendData=========")
    end
end

function IosAppUtils:sendExtendDataRoleCreate(infoTable)
    local args = infoTable
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"sendExtendDataRoleCreate",args)
    if not ok then
    else
        print("========sendExtendDataRoleCreate=========")
    end
end

function IosAppUtils:sendExtendDataRoleLevelUp(infoTable)
    local args = infoTable
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"sendExtendDataRoleLevelUp",args)
    if not ok then
    else
        print("========sendExtendDataRoleLevelUp=========")
    end
end

function IosAppUtils:canShowFloatIcon(flag)
    local infoTable = {}
    infoTable["flag"] = tostring(flag)
    infoTable["float"] = "2"
    local args = infoTable
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"canShowFloatIcon",args)
    if not ok then
    else
        print("========sendExtendDataRoleLevelUp=========")
    end
end

function IosAppUtils:showWebHtmlView(url)
    local args = {}
    args["url"] = tostring(url)
    if string.find(url,"http://") == nil then
        args["isLocal"] = "true"   --本地的html
    else
        args["isLocal"] = "false"   --服务器传来的
    end
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"showWebHtmlView",args)
    if not ok then
    else
        print("========showWebHtmlView=========")
    end
end

function IosAppUtils:setPushTags(tagsJson)
    local args = { tagsJson = tagsJson}
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"setPushTags",args)
    if not ok then
    else
        print("========setPushTags=========")
    end
end


function IosAppUtils:downloadHeadPic(headInfo)
    local args = { headInfo = headInfo}
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"downloadHeadPic",args)
    if not ok then
    else
        print("========downloadHeadPic=========")
    end
end

--0 = 相册
--1 = 相机
function IosAppUtils:showSelectPicUpload(headInfo)
    local args = { headInfo = headInfo}
    local luaoc = require "luaoc"
    local className = "LuaObjectCBridge"
    local ok,ret  = luaoc.callStaticMethod(className,"showSelectPicUpload",args)
    if not ok then
    else
        print("========showSelectPicUpload=========")
    end
end



return IosAppUtils