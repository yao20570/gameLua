
local AndroiFiledUtils = {}

local rootDir = "znlGame"
--获取Android的sd路径
function AndroiFiledUtils:getSDPath()
    local path = nil
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"getSDPath",args,sigs)
    if not ok then
        print("luaj error: ", tostring(ret))
    else
        path = tostring(ret) .. "/" .. rootDir .. "/"
        local result = self:isFolderExists(path)
        if result ~= true then
            path = nil
        end
    end
    return path
end

function AndroiFiledUtils:isFolderExists(path)
    local result = false
    local args = {path}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"isFolderExists",args,sigs)
    if not ok then
        print("luaj error: %s", tostring(ret))
    else
        print("------isFolderExists------", tostring(ret))
        result = ret
    end
    return result
end


function AndroiFiledUtils:deleteFolder(path)
    local result = false
    local args = {path}
    local sigs = "(Ljava/lang/String;)Z"
    local luaj = require "luaj"
    local className = "com/cocos2dx/znlGame/LuaJavaBridgeTest"
    local ok,ret  = luaj.callStaticMethod(className,"deleteFolder",args,sigs)
    if not ok then
        print("luaj error: %s", tostring(ret))
    else
        print("------deleteFolder------", tostring(ret))
        result = ret
    end
    return result
end




return AndroiFiledUtils
