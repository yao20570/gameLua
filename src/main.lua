require "Cocos2d"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    if logger ~= nil then
        logger:error("----------------------------------------")
        logger:error("LUA ERROR: " .. tostring(msg))
        logger:error(debug.traceback())
        logger:error("----------------------------------------")
    else
        cclog("----------------------------------------")
        cclog("LUA ERROR: " .. tostring(msg) .. "\n")
        cclog(debug.traceback())
        cclog("----------------------------------------")
    end
    
    if _G["onLuaException"] ~= nil then
        setUserInfo(GameConfig.accountName)
        onLuaException(tostring(msg), debug.traceback())
    end
    return msg
end

local function addTempSearchPath()
    if _G["createDownloadDir"] == nil then
        return
    end

    local pathToSave = ""
    local mainVersion = require("version")
    pathToSave = createDownloadDir("tmpdir" .. mainVersion)

    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)
    addSearchPath(pathToSave .. "/res/ccb/ccbi", true)
    addSearchPath(pathToSave,true)

    local pathToSave = createDownloadDir("tmpres" .. mainVersion)
    addSearchPath(pathToSave,true)
    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)


    pathToSave = createDownloadDir("tmppre" .. mainVersion)
    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)
    addSearchPath(pathToSave,true)

    pathToSave = createDownloadDir("tmppreres" .. mainVersion)
    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)
    addSearchPath(pathToSave,true)

    package.loaded["framework.platform.FileUtils"] = nil
    package.loaded["framework.platform"] = nil
    package.loaded["framework"] = nil
end

_G["addTempSearchPath"] = addTempSearchPath

local function main()
    collectgarbage("collect")--启动内存自动回收机制
    -- avoid memory leak
    collectgarbage("setpause", 100)--收集时长
    collectgarbage("setstepmul", 5000)--收集步长

    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.FileUtils:getInstance():addSearchPath("res/ccb/ccbi")
    cc.FileUtils:getInstance():addSearchPath("html")
    cc.FileUtils:getInstance():addSearchPath("firstSrc")
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
        require("iosGameMain")
    else
        _G["addTempSearchPath"]() --需要加搜索路径！！！
        require("GameMain")
    end

end






local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
