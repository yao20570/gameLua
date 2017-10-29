local AndroiAppUtils = {}

function AndroiAppUtils:isInitSDKFinish()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"isInitSDKFinish",args,sigs)
    if not ok then
        logger:error("isInitSDKFinish error: %s", tostring(ret))
    else
        logger:info("------isInitSDKFinish------", tostring(ret))
        result = ret
    end
    
    return result
end

function AndroiAppUtils:showLoginView()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showLoginView",args,sigs)
    if not ok then
        logger:error("showChargeView error: %s", tostring(ret))
    else
        logger:info("------showLoginView------", tostring(ret))
        result = ret
    end
    
    return result
end

function AndroiAppUtils:showReLogionView()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showReLogionView",args,sigs)
    if not ok then
        logger:error("showReLogionView error: %s", tostring(ret))
    else
        logger:info("------showReLogionView------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:isReLoginView()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"isReLoginView",args,sigs)
    if not ok then
        logger:error("isReLoginView error")
    else
        logger:info("------isReLoginView------")
        result = ret
    end
    
    return result
end


function AndroiAppUtils:sdkLogOut()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"sdkLogOut",args,sigs)
    if not ok then
        logger:error("sdkLogOut error: %s", tostring(ret))
    else
        logger:info("------sdkLogOut------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:showChargeView(infoJson)
    local result = false
    local args = {infoJson}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showChargeView",args,sigs)
    if not ok then
        logger:error("showChargeView error: %s", tostring(ret))
    else
        logger:info("------showChargeView------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:initSDKExtendData(infoTable)
    require("json")
    local infoJson = json.encode(infoTable)
    local result = false
    local args = {infoJson}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"initSDKExtendData",args,sigs)
    if not ok then
        logger:error("initSDKExtendData error: %s", tostring(ret))
    else
        logger:info("------initSDKExtendData------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:sendExtendDataRoleCreate(infoTable)
    require("json")
    local infoJson = json.encode(infoTable)
    local result = false
    local args = {infoJson}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"sendSDKExtendDataRoleCreate",args,sigs)
    if not ok then
        logger:error("initSDKExtendData error: %s", tostring(ret))
    else
        logger:info("------initSDKExtendData------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:sendExtendDataRoleLevelUp(infoTable)
    require("json")
    local infoJson = json.encode(infoTable)
    local result = false
    local args = {infoJson}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"sendSDKExtendDataRoleLevelUp",args,sigs)
    if not ok then
        logger:error("initSDKExtendData error: %s", tostring(ret))
    else
        logger:info("------initSDKExtendData------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:getPhoneInfo()
    local phoneInfo = ""
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"getPhoneInfo",args,sigs)
    if not ok then
        print("luaj error: ", tostring(ret))
    else
        phoneInfo = ret
    end
    
    return phoneInfo
end

function AndroiAppUtils:showWebHtmlView(url)
    local result = false
    local args = {url}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showWebHtmlView",args,sigs)
    if not ok then
        logger:error("showWebHtmlView error: %s", tostring(ret))
    else
        logger:info("------showWebHtmlView------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:showOldWebHtmlView(url)
    local result = false
    local args = {url}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showOldWebHtmlView",args,sigs)
    if not ok then
        logger:error("showOldWebHtmlView error: %s", tostring(ret))
    else
        logger:info("------showOldWebHtmlView------", tostring(ret))
        result = ret
    end

    return result
end
function AndroiAppUtils:openGmPage(url)
    local result = false
    local args = {url}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"openGmPage",args,sigs)
    if not ok then
        logger:error("openGmPage error: %s", tostring(ret))
    else
        logger:info("------openGmPage------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:showSelectPicUpload(headInfo)

    if CustomHeadManager:checkAndroidVersionNotSupport(true) then
        return
    end

    local result = false
    local args = {headInfo}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showSelectPicUpload",args,sigs)
    if not ok then
        logger:error("showSelectPicUpload error: %s", tostring(ret))
    else
        logger:info("------showSelectPicUpload------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:downloadHeadPic(headInfo)

    if CustomHeadManager:checkAndroidVersionNotSupport() then
        return
    end

    local result = false
    local args = {headInfo}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"downloadHeadPic",args,sigs)
    if not ok then
        logger:error("downloadHeadPic error: %s", tostring(ret))
    else
        logger:info("------downloadHeadPic------", tostring(ret))
        result = ret
    end

    return result
end


function AndroiAppUtils:showBaiduASRDigitalDialog()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"showBaiduASRDigitalDialog",args,sigs)
    if not ok then
        logger:error("showBaiduASRDigitalDialog error: %s", tostring(ret))
    else
        logger:info("------showBaiduASRDigitalDialog------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:hideBaiduASRDigitalDialog()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"hideBaiduASRDigitalDialog",args,sigs)
    if not ok then
        logger:error("hideBaiduASRDigitalDialog error: %s", tostring(ret))
    else
        logger:info("------hideBaiduASRDigitalDialog------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:cancelBaiduASRDigitalDialog()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"cancelBaiduASRDigitalDialog",args,sigs)
    if not ok then
        logger:error("cancelBaiduASRDigitalDialog error: %s", tostring(ret))
    else
        logger:info("------cancelBaiduASRDigitalDialog------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:setMaxRecorderTime(maxTime)
    local result = false
    local args = {maxTime}
    local sigs = "(I)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"setMaxRecorderTime",args,sigs)
    if not ok then
        logger:error("setMaxRecorderTime error: %s", tostring(ret))
    else
        logger:info("------setMaxRecorderTime------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:calcMD5(str)
    local md5 = ""
    local args = {str}
    local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"calcMD5",args,sigs)
    if not ok then
        print("luaj error: ", tostring(ret))
    else
        md5 = ret
    end
    
    return md5
end

function AndroiAppUtils:setAnimationInterval(interval)
    local args = {interval}
    local sigs = "(I)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"setAnimationInterval",args,sigs)
    if not ok then
        print("luaj error: ", tostring(ret))
    else
    end
end

function AndroiAppUtils:setPushTags(tagsJson)
    local result = false
    local args = {tagsJson}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"setPushTags",args,sigs)
    if not ok then
        logger:error("setPushTags error: %s", tostring(ret))
    else
        logger:info("------setPushTags------", tostring(ret))
        result = ret
    end

    return result
end

function AndroiAppUtils:gameLogout()
    local result = false
    local args = {}
    local sigs = "()Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"gameLogout",args,sigs)
    if not ok then
        logger:error("gameLogout error: %s", tostring(ret))
    else
        logger:info("------gameLogout------", tostring(ret))
        result = ret
    end
    
    return result
end

function AndroiAppUtils:filterEmoji(text)
    local result = text
    local args = {text}
    local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className, "filterEmoji", args, sigs)
    if not ok then
        logger:error("filterEmoji error: %s", tostring(ret))
    else
        logger:info("------filterEmoji------", tostring(ret))
        result = ret
    end

    return result
end

-----------设置是否可以多点触控
function AndroiAppUtils:setMultipleTouchEnabled(enabled)
    local result = false
    local args = {enabled}
    local sigs = "(Z)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"setMultipleTouchEnabled",args,sigs)
    if not ok then
        logger:error("setMultipleTouchEnabled error: %s", tostring(ret))
    else
        logger:info("------setMultipleTouchEnabled------", tostring(ret))
        result = ret
    end
    
    return result
end


return AndroiAppUtils





