
PhoneInfo = {}

function PhoneInfo:init(info)
    
    local targetPlatform= cc.Application:getInstance():getTargetPlatform()
    local os = 4
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        os = 1
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE 
        or targetPlatform == cc.PLATFORM_OS_IPAD then
        os = 2
    elseif targetPlatform == cc.PLATFORM_OS_WINDOWS then
        os = 3
    end
    info["os"] = os
    
    GameConfig.osName = self:getOsName(os)
    
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local screen = frameSize.width .. "x" .. frameSize.height
    info["screen"] = screen
    
    
    GameConfig.platformChanleId = info["plat_id"] or -1
    
    if info["mac"] ~= nil then
        info["imei"] = info["imei"] or "null"
        local utma = AppUtils:calcMD5(info["model"] .. info["mac"] .. info["imei"])
        info["utma"] = utma
    else
        info["utma"] = ""
    end
    
    if targetPlatform == cc.PLATFORM_OS_IPHONE 
        or targetPlatform == cc.PLATFORM_OS_IPAD then
        local utma =  AppUtils:calcMD5(info["imei"])
        info["utma"] = utma
    end
    
    if info["isOpenCharge"] ~= nil and 
        (info["isOpenCharge"] == "false" or info["isOpenCharge"] == false )then
        GameConfig.isOpenCharge = false
    end
    
    if info["isShowLogo"] ~= nil and 
        (info["isShowLogo"] == "false" or info["isShowLogo"] == false )then
        GameConfig.isShowLogo = false
    end
    
    if info["autoLoginDebug"] ~= nil and 
        (info["autoLoginDebug"] == "true" or info["autoLoginDebug"] == true )then
        GameConfig.autoLoginDebug = true
        GameConfig.platformChanleId = 9988 --给没有SDK登录的写死一个渠道ID
    end

    if info["isTriggerGuide"] ~= nil and 
        (info["isTriggerGuide"] == "false" or info["isTriggerGuide"] == false )then
        GameConfig.isTriggerGuide = false
    end

    if info["isFullPackage"] ~= nil and 
        (info["isFullPackage"] == "false" or info["isFullPackage"] == false )then
        GameConfig.isFullPackage = false
    end

    if info["isActivation"] ~= nil and 
        (info["isActivation"] == "false" or info["isActivation"] == false )then
        GameConfig.isActivation = false
    end

    if info["channelId"] ~= nil then
        GameConfig.channelId = info["channelId"]
    end
    
    GameConfig.logoId = info["logoId"] or 0

    if info["versionUrl"] ~= nil and info["versionUrl"] ~= "" then
        GameConfig.phoneVersionUrl = info["versionUrl"]
    end

    if type(info["phoneVersion"]) == "string" and  info["phoneVersion"] ~= "" then
        GameConfig.phoneVersion = info["phoneVersion"]
    end
    
    self._info = info
end

--拿到即将要发送给服务器的手机信息
function PhoneInfo:getPackPhoneInfo()
    local data = {}
    data["utma"] = self:getInfoByKey("utma") or ""
    data["imei"] = ( (self:getInfoByKey("mac") or "" ).. "_" .. (self:getInfoByKey("imei") or "") ) or ""
    data["screen"] = self:getInfoByKey("screen") 
    data["os"] = self:getInfoByKey("os")
    data["model"] = self:getInfoByKey("model") or ""
    data["net"] = self:getNetName(self:getInfoByKey("net") or "") 
    data["operators"] = self:getOperators(self:getInfoByKey("operators") or "") 
    data["location"] = self:getInfoByKey("location") or ""
    data["package_name"] = self:getInfoByKey("package_name") or ""
    data["package_size"] = self:getInfoByKey("package_size") or ""
    data["plat_id"] = self:getInfoByKey("plat_id") or GameConfig.platformChanleId
    data["game_version"] = GameConfig.version
    
    local phoneInfo = self:reGetPhoneInfo() --登录时再去拿一遍。pushChannelId初始化会满 这里只能拿pushChannelId
    data["pushChannelId"] = phoneInfo["pushChannelId"] or ""
    data["channal_id"] = phoneInfo["channelId"] or 0
    
    local phoneVersion = self:getInfoByKey("phoneVersion")
    if type(phoneVersion) == "string" and phoneVersion ~= "" then
        data["os_version"] = phoneVersion
    end
    return data
end

function PhoneInfo:getLoginData(account, areId)
    local data = self:getPackPhoneInfo()
    data["account"] = account
    data["areId"] = areId
    return data
end

function PhoneInfo:getOsName(os)
    local name = "other"
    if os == 1 then
        name = "android"
    elseif os == 2 then
        name = "ios"
    elseif os == 3 then
        name = "windows"
    end
    return name
end

function PhoneInfo:getNetName(net)
    local name = "other"
    if net == 1 then
        name = "2G"
    elseif net == 2 then
        name = "3G"
    elseif net == 3 then
        name = "wifi"
    end
    return name
end

function PhoneInfo:getOperators(operators)
    local name = "其他"
    if operators == 1 then
        name = "中国移动"
    elseif operators == 2 then
        name = "中国联通"
    elseif operators == 3 then
        name = "中国电信"
    end
    return name
end

function PhoneInfo:reGetPhoneInfo()
    local phoneInfo = AppUtils:getPhoneInfo() or ""
    logger:error("~~~not==error==getPhoneInfo=~~~:%s~~~", phoneInfo)
    require("json")
    local function decode()
        local result = json.decode(phoneInfo)
        return result
    end
    local status, phoneInfoData = pcall(decode)
    if status ~= true then
        logger:error("~~~~~~~PhoneInfo解析失败~~~~~~~~~~~~~~~")
        phoneInfoData = {}
    end
    return phoneInfoData
end


--imei IMEI
--location 地理坐标
--operators 运营商
--model 手机机型
--package_name 游戏包名称
--net 网络 1、2G；2、3G；3、wifi；4、其他
--package_size 游戏包大小(字节数)
--utma 手机唯一标识:md5(imei+手机机型+网卡mac)
--plat_id 平台ID
--screen分辨率
--os操作系统
function PhoneInfo:getInfoByKey(key)
    return self._info[key]
end

function PhoneInfo:getPhoneInfo()
    return self._info
end



