
AppFileUtils = {}
AppFileUtils.writablePath = nil

function AppFileUtils:getWritablePath()
    if self.writablePath ~= nil then
        return self.writablePath
    end
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    
    local path = nil
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local AndroiFiledUtils = require("framework.platform.android.AndroidFileUtils")
        path = AndroiFiledUtils:getSDPath()
    end
    
    if path == nil then
        path = cc.FileUtils:getInstance():getWritablePath()
    end
    
    self.writablePath = path
    
    return path
end

--路径不存在则创建
--创建成功返回true
function AppFileUtils:isFolderExists(path)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()

    local result = false
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local AndroiFiledUtils = require("framework.platform.android.AndroidFileUtils")
        result = AndroiFiledUtils:isFolderExists(path)
    end
    
    return result
end

function AppFileUtils:deleteFolder(path)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    local result = false
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local AndroiFiledUtils = require("framework.platform.android.AndroidFileUtils")
        result = AndroiFiledUtils:deleteFolder(path)
    end
    
    return result
end

function AppFileUtils:addTempSearchPath()
    local mainVersion = require("version")
    local writablePath = self:getWritablePath()
    local sdkPath = writablePath .. "/" .. "tmpdir" .. mainVersion
    local result = self:isFolderExists(sdkPath)
    
    local pathToSave = ""
    if result == false then
        if createDownloadDir ~= nil then
            pathToSave = createDownloadDir("tmpdir" .. mainVersion)
        end
    else
        pathToSave = sdkPath
    end

    cc.FileUtils:getInstance():addSearchPath(pathToSave .. "/src", true)
    cc.FileUtils:getInstance():addSearchPath(pathToSave .. "/res", true)
    cc.FileUtils:getInstance():addSearchPath(pathToSave,true)
end















