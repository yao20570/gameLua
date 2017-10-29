LocalDBManager  = {}

function LocalDBManager:init()
    local path = AppFileUtils:getWritablePath()
    self.filename = path .. "/game.db"
    
    self.db = {}
    logger:error("开始读取缓存数据:" .. os.clock())
    self:initRead()
    logger:error("结束读取缓存数据:" .. os.clock())
end


function LocalDBManager:initRead()
    local isSame = false --有相同的，重新刷新下缓存
    
    local file = io.open(self.filename,'r')
    if file ~= nil then
        local data = file:read("*a")
        local dataAry = framework.utils.StringUtils:splitString(data, "\n")
        for _, kvStr in pairs(dataAry) do
            local kvAry = framework.utils.StringUtils:splitString(kvStr, " ")
            local key = tostring(kvAry[1])
            local value = tostring(kvAry[2])
            if self.db[key] ~= nil then
                isSame = true
            end
            self.db[key] = value
        end
        
        file:close()
    end
    
    local str = ""
    
    if isSame == true then
        for key, value in pairs(self.db) do
            str = str .. key .. " " .. value .. "\n"
        end
    end
    
    if str ~= "" then
        local file = io.open(self.filename,'w')
        if file ~= nil then
            file:write(str)
            file:flush()
            file:close()
        end
    end
end


--将proto数据写入文件
----[[-
----name: 协议定义，比如M23.M230000.S2C
----data: table
--]]
function LocalDBManager:writeProtobuf(filename, name, data)
    local msg = protobuf.encode(name , data)

    local file = io.open(filename,'wb')
    if file ~= nil then
        file:write(msg)
        file:flush()
        file:close()
    end

    return msg

end

--读取proto文件数据
function LocalDBManager:readProtobuf(filename, name)
    
    local file = io.open(filename,'r')
    if file ~= nil then
        local msg = file:read("*a")
        local data = protobuf.decode(name , msg)

        file:close()
        return data
    end

    return nil

end


---------------------UserDefault实现本地保存方式--------------------------------------------------

function LocalDBManager:setValueForKey(key, value, isGloble)
    local mainKey
    if isGloble == true then
        mainKey = ""
    else
        mainKey = GameConfig.serverId .. StringUtils:fixed64ToNormalStr(GameConfig.actorid)
    end

--    local kvStr = mainKey .. key .. " " .. value 
    
    key = "L" .. mainKey .. key
    
--    if self._saveKeyMap == nil then
--        self._saveKeyMap = {}
--    end
--    self._saveKeyMap[key] = 1
    
    cc.UserDefault:getInstance():setStringForKey(key, tostring(value))
    cc.UserDefault:getInstance():flush()
    
end

function LocalDBManager:getValueForKey(key, isGloble, extraKey)
    local mainKey
    if isGloble == true then
        mainKey = ""
    elseif extraKey ~= nil then
        mainKey = GameConfig.serverId .. GameConfig.accountName
    else
        mainKey = GameConfig.serverId .. StringUtils:fixed64ToNormalStr(GameConfig.actorid)
    end
    key = "L" .. mainKey .. key
    
    local value = cc.UserDefault:getInstance():getStringForKey(key)
    if value == "" then
        value = nil
    end
    return value
end

function LocalDBManager:clear()
    for key, _ in pairs(self._saveKeyMap) do
    	self:setValueForKey(key, "")
    end
    self._saveKeyMap = {}
end



--LocalDBManager:init()