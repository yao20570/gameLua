
require("json")

KKKLog = {}

local url = "http://wakuang.3kwan.com/"
local key = "6kEQ#7Gt!edAPxNEPeTrEpwPdrTQbCTA2ewV5cnJnuWbmyVpN49tDucSbeSe8JXSwrAfLy3VF9PqM2etmXQ3FVQREprJYczsbCEY9cPZv3TfeSb"

--SDK账号登录
function KKKLog:accountLoginLog()

    local requestKey = GameConfig.accountName .. "is_request"

    local is_request = LocalDBManager:getValueForKey(requestKey,true)
    if is_request ~= nil then
        GameConfig.is_request = false
    end
    
    local mainKey = "user"
    local subKey = "login"
    
    local params = self:getBaseData()
    
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    
    params = self:packLogData(mainKey,subKey,params)
    
    local function callback(info)
        info = string.gsub(info,"\\u","")
        local data = json.decode(info)
        local state = data.state
        if state == true then
            logger:error("--no-error----后台登录成功--------------")
        else
            logger:error("--no-error----后台登录失败--------------")
        end
        local is_reg_account = data.is_reg_account or true
        GameConfig.is_request = is_reg_account
        if is_reg_account == false then
            game.manager.LocalDBManager:setValueForKey(requestKey,"true",true)
        end
    end
    LogUtils:send(mainKey,subKey,params,url, callback)
end

-------------------------------------------------------

--角色创建成功
function KKKLog:addRoleLog(roleInfo)

    local mainKey = "role"
    local subKey = "add"
    
    local params = self:getBaseData()
    params["role_id"] = roleInfo.actorid
    params["role_name"] = roleInfo.name
    
    params = self:packLogData(mainKey,subKey,params)
    LogUtils:send(mainKey, subKey,params,url)
    
    GameConfig.actorid = roleInfo.actorid
    GameConfig.actorName = roleInfo.name
    local userMoney = roleInfo.diamond
    GameConfig.level = roleInfo.summonLevel
    SDKManager:sendExtendDataRoleCreate(userMoney)
end

--角色登录 3
function KKKLog:roleLoginLog(roleInfo)
    local params = self:getBaseData()
    params["role_id"] = roleInfo.actorid
    params["role_name"] = roleInfo.name
    params["role_level"] = roleInfo.stars
    params["vip_level"] = roleInfo.viplevel
    params["gold"] = roleInfo.diamond
    params["coin"] = roleInfo.money
    
    params = self:packLogData("role","login",params)
    LogUtils:send("role","login",params,url)
    
end

--角色等级更新
function KKKLog:roleLevelUpdateLog(roleInfo)
    local params = self:getBaseData()
    params["role_id"] = roleInfo.actorid
    params["role_level"] = roleInfo.stars

    params = self:packLogData("role","level",params)
    LogUtils:send("role","level",params,url)
end

function KKKLog:roleUpdateLog(roleInfo)
    local params = self:getBaseData()
    params["role_id"] = roleInfo.actorid
    params["role_name"] = roleInfo.name
    params["role_level"] = roleInfo.stars
    params["vip_level"] = roleInfo.viplevel
    params["gold"] = roleInfo.diamond
    params["coin"] = roleInfo.money

    params = self:packLogData("role","update",params)
    LogUtils:send("role","update",params,url)
end

---------------注册流失日志-----------------------------

--选服
function KKKLog:selectServerLog()
    if GameConfig.is_request == false then --该账号已经注册了，不需要发送日志
        return
    end
    
    local params = self:getBaseData()
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    params["fill_register_msg_times"] = GameConfig.registerOverTime - GameConfig.showLoginViewTime
    
    params = self:packLogData("register_statis","select_server",params)
    LogUtils:send("register_statis","select_server",params,url)
end

--进入角色资源加载页面
function KKKLog:enterUserInterfaceLogingLog()
    if GameConfig.is_request == false then --该账号已经注册了，不需要发送日志
        return
    end
    
    local params = self:getBaseData()
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    params["fill_register_msg_times"] = GameConfig.registerOverTime - GameConfig.showLoginViewTime
    
    params = self:packLogData("register_statis","enter_user_interface_loading",params)
    LogUtils:send("register_statis","enter_user_interface_loading",params,url)
end

--进入角色选择界面
function KKKLog:enterUserInterface()
    if GameConfig.is_request == false then --该账号已经注册了，不需要发送日志
        return
    end
    local params = self:getBaseData()
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    params["fill_register_msg_times"] = GameConfig.registerOverTime - GameConfig.showLoginViewTime

    params = self:packLogData("register_statis","enter_user_interface",params)
    LogUtils:send("register_statis","enter_user_interface",params,url)
end

--角色创建成功
function KKKLog:finishCreate()
    if GameConfig.is_request == false then --该账号已经注册了，不需要发送日志
        return
    end
    local params = self:getBaseData()
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    params["fill_register_msg_times"] = GameConfig.registerOverTime - GameConfig.showLoginViewTime

    params = self:packLogData("register_statis","finish_create",params)
    LogUtils:send("register_statis","finish_create",params,url)
end

--角色进入游戏(主场景)资源加载界面
function KKKLog:intoGameLoading()
    if GameConfig.is_request == false then --该账号已经注册了，不需要发送日志
        return
    end
    local params = self:getBaseData()
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    params["fill_register_msg_times"] = GameConfig.registerOverTime - GameConfig.showLoginViewTime

    params = self:packLogData("register_statis","into_game_loading",params)
    LogUtils:send("register_statis","into_game_loading",params,url)
end

--角色进入游戏(主场景)界面
function KKKLog:intoGame()
    if GameConfig.is_request == false then --该账号已经注册了，不需要发送日志
        return
    end
    local params = self:getBaseData()
    local startup_times = GameConfig.showLoginViewTime - GameConfig.startGameTime
    params["startup_times"] = startup_times
    params["fill_register_msg_times"] = GameConfig.registerOverTime - GameConfig.showLoginViewTime

    params = self:packLogData("register_statis","into_game",params)
    LogUtils:send("register_statis","into_game",params,url)
end

---------------------------------------------------------------------------------

-------------------------------日志统计接口-------

--激活统计
function KKKLog:logActiveLog()
    local isLogActive = cc.UserDefault:getInstance():getIntegerForKey("isLogActive")
    if isLogActive ~= 1 then
        
        local function callback(info)
            info = string.gsub(info,"\\u","")
            local data = json.decode(info)
            local state = data.state
            if state == true then
                logger:error("===========not==error====日志统计激活成功===========")
                
                cc.UserDefault:getInstance():setIntegerForKey("isLogActive", 1)
                cc.UserDefault:getInstance():flush()

            end
        end
        
        local params = self:getBaseData()
        params = self:packLogData("make_log","log_active",params)
        LogUtils:send("make_log","log_active",params,url, callback)
    end
end

--玩家金币操作统计
--op_type 操作类型，1增加、0消费
--type 使用金币类型，增加：1日常挂机,2抽牌奖励,3登录奖励,4首充奖励,5首购月卡,6超值礼包,7道具使用
--消费：
--51佣兵觉醒,52神殿解锁,53商会解锁,54抽牌消耗,55商会兑换,56招募",
--coin 得到 /减少金币数
--remain_coin 剩余金币数

function KKKLog:logUserCoinLog(op_type, type, coin, remain_coin, roleInfo )
    local params = self:getBaseData()
    params["role_id"] = roleInfo.actorid
    params["role_name"] = roleInfo.name
    
    params["op_type"] = op_type
    params["type"] = type
    params["coin"] = coin
    params["remain_coin"] = remain_coin
    
    params = self:packLogData("make_log","log_user_coin",params)
    LogUtils:send("make_log","log_user_coin",params,url)
end

--玩家血钻操作统计
function KKKLog:logUserGoldLog(op_type, type, gold, remain_gold, roleInfo)
    local params = self:getBaseData()
    params["role_id"] = roleInfo.actorid
    params["role_name"] = roleInfo.name

    params["op_type"] = op_type
    params["type"] = type
    params["gold"] = gold
    params["remain_gold"] = remain_gold

    params = self:packLogData("make_log","log_user_gold",params)
    LogUtils:send("make_log","log_user_gold",params,url)
end



------------------------------------

function KKKLog:getBaseData()
    local data = PhoneInfo:getPhoneInfo()
    data = clone(data)
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if(cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        data["plat_id"] = -1
    end
    
    if data["plat_id"] == nil then
        data["plat_id"] = -1
    end
    
    return data
end

function KKKLog:packLogData(mainKey, subKey, data)
    local server_id = GameConfig.serverId
    local user_name = data["plat_id"] .. "_" ..GameConfig.userId --GameConfig.accountName 平台帐号即(平台标志_平台用户ID)
    local token_time = AppUtils:calcMD5(data["utma"] .. os.time() .. math.random(100000,999999))
    
    data["server_id"] = server_id
    data["user_name"] = user_name
    data["token_time"] = token_time

    if self._paramKeyList == nil then
        self._paramKeyList = {}
    end
    
    if self._paramKeyList[mainKey .. "-" .. subKey] == nil then
        self._paramKeyList[mainKey .. "-" .. subKey] = {}
        
        for key, _ in pairs(data) do
            table.insert(self._paramKeyList[mainKey .. "-" .. subKey], key)
        end
        table.sort(self._paramKeyList[mainKey .. "-" .. subKey])
    end
    
    local list = self._paramKeyList[mainKey .. "-" .. subKey]
    local str = ""
    for _, key in pairs(list) do
        if data[key] ~= nil then
            str = str .. data[key]
        end
    end
    

    local sign = AppUtils:calcMD5(str .. key)
    
    data["sign"] = sign
    
    return data
end






















