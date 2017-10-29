-------------------------------------------------------------------------------
-- Prints logging information to console
--
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
--
-------------------------------------------------------------------------------

local logging = require("framework.log.logging")

function logging.custom(logPattern)

    --控制台
    local function console(self, level, message)
        print(logging.prepareLogMsg(logPattern, os.date(), level, message )) --.. debug.traceback()
        return true
    end
    
    --文件输出
    --IO过于频繁，需要优化 定时写入
    
    local logInfo = ""
    local filename    = "znlGame"..os.date("_%Y_%m_%d")..'.txt'
    local path = AppFileUtils:getWritablePath()
    filename    = path .. filename
    local ofile  = io.open(filename,"a")
    
    local function file(self, level, message)
        
        local log = logging.prepareLogMsg(logPattern, os.date(), level, message)
--        logInfo = logInfo .. log
        ofile:write(log)
        ofile:flush()
        
        return true
    end
    
    local function log(self, level, message)

        if GameConfig ~= nil and GameConfig.packageInfo == 2 and GameConfig.phoneVersionUrl == "" then
            return true --正式包不写日志了 会上传到服务器的
        end

        if GameConfig ~= nil and GameConfig.packageInfo == 5 and GameConfig.phoneVersionUrl == "" then
            return true --正式包不写日志了 会上传到服务器的
        end

        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        -- if targetPlatform == cc.PLATFORM_OS_WINDOWS then
            console(self, level, message)
        -- end
        
        file(self, level, message)
        return true
    end
    
--    local function update()
--        if logInfo ~= "" then
--            ofile:write(logInfo)
--            ofile:flush()
--
--            logInfo = ""
--        end
--    end
--    
--    cc.Director:getInstance():getScheduler():scheduleScriptFunc(update,10,false)

    return logging.new( log )
end


return logging.custom

