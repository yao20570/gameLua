
--充值管理器
SDKManager = {}

SDKManager.orderId = 0

--获取商品ID，确保唯一性
--年月日时分秒+3位游戏代号+2位运营商代号+4位随机数 共23位
function SDKManager:getProductId(amount, chargeType)
    local platId = GameConfig.platformChanleId
    
    GameConfig.chargePlatId = 87

    if platId == 127 then  --三星渠道 直接写死1
        return 1
    end

    if platId == 32 then --魅族渠道 直接写死1
        return 1
    end

    
    local productId = ConfigDataManager:getChargeProductId(amount,chargeType,platId)
    if productId ~= nil and productId ~= "" then
        return productId
    end

    -- local date = TimeUtils:getCurDateStr()
    -- local gameId = GameConfig.gameId
    -- local platformChanleId = string.format("%02d", platId)
    -- local r1 = math.random(0,9)
    -- local r2 = math.random(0,9)
    -- local r3 = math.random(0,9)
    -- local r4 = math.random(0,9)
    
    -- local productId = date .. gameId .. platformChanleId .. r1 .. r2 .. r3 .. r4
    --魅族渠道：支付失败：产品ID（product_id）大于32位或产品ID参数无效
    --修改：所有的没有productId的渠道，都默认为1
    productId = 1
    return productId
end

function SDKManager:isChargeShow(rechargeInfo)
    local flag = true
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform or 
        cc.PLATFORM_OS_IPAD == targetPlatform then
        if rechargeInfo.money == 1998 then
            flag = false
        end
    end
    return flag
end


function SDKManager:setGameState(gameState)
    self._gameState = gameState
end

--amount  单位 元
function SDKManager:charge(amount, chargeType,name,code)

    if GameConfig.autoLoginDebug ==  true then
        print("=====GameConfig.autoLoginDebug ==  true  so return====")
        return
    end
    
--     if GameConfig.isOpenCharge == false and GameConfig.platformChanleId ~= 0 then --开启充值配置 非3K平台
-- --        component.SysMessage:show("充值功能暂未开启，敬请期待!")
--         print("============开启充值配置 非3K平台==================")
--         return
--     end

    if GameConfig.isOpenCharge == false then
        self._gameState:showSysMessage("充值功能暂未开启，敬请期待!")
        return
    end
    
    --IOS的充值
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform or 
        cc.PLATFORM_OS_IPAD == targetPlatform then
        GameConfig.chargePlatId = 187
        print("===========click button come to SDKManager:charge============")
        local info = {}
        info["roleId"] = StringUtils:fixed64ToNormalStr(GameConfig.actorid)--tostring(GameConfig.actorid)
        info["serverId"] = GameConfig.serverId
        info["serverName"] = GameConfig.serverName
        info["orderTitle"] = ConfigDataManager:getChargeProductName(amount,chargeType)--name--
        info["notifyURL"] = GameConfig.payCallbackURL
        info["userInfo"] = tostring(chargeType)
        info["amount"] = amount
        info["productId"] = ConfigDataManager:getChargeProductId(amount,chargeType, GameConfig.chargePlatId) --商品ID，生成规则 "xuezuan60"--
        info["identifiers"] = ConfigDataManager:getChargeProductGroup(GameConfig.chargePlatId,"GCOL") --"xuezuan60,xuezuan300,xuezuan980,xuezuan1980,xuezuan3280,xuezuan6480"
        AppUtils:showChargeView(info)
        return
    end

    chargeType = chargeType or 0
    local infoTable = {}
    infoTable["amount"] = amount * 100 --SDK的单位为分
    infoTable["serverId"] = GameConfig.serverId
    infoTable["roleId"] = StringUtils:fixed64ToNormalStr(GameConfig.actorid)
    infoTable["roleName"] = tostring(GameConfig.actorName)
    infoTable["rate"] = 10 --待定
    infoTable["productName"] = ConfigDataManager:getChargeProductName(amount, chargeType, GameConfig.platformChanleId) --"血钻"
    infoTable["serverName"] = GameConfig.serverName
    infoTable["callBackInfo"] = tostring(chargeType)
    infoTable["productId"] = self:getProductId(amount, chargeType) --商品ID，生成规则
    infoTable["callbackURL"] = GameConfig.payCallbackURL
    infoTable["lastMoney"] = "0"
    infoTable["roleLevel"] = tostring(GameConfig.level)
    infoTable["sociaty"] = "null"
    infoTable["vipLevel"] = tostring(GameConfig.vipLevel)
    
    self.orderId = infoTable["productId"]
    local iapId = ""
    if chargeType == 1 then
        iapId = "月卡"
    else
        iapId = "购买" .. (amount * 10) .. "元宝"
    end
    
    require("json")
    local infoJson = json.encode(infoTable)
    
    AppUtils:showChargeView(infoJson)
    
    
    if GameConfig.targetPlatform == cc.PLATFORM_OS_WINDOWS then
--        component.SysMessage:show("进入测试充值沙箱")
        logger:error("充值数据：amount:%d, chargeType:%d", amount, chargeType)
       -- self:testSendServerCharge(infoTable)
        
--        self:testCharge(infoTable)
    end
--    if game.const.GameConfig.targetPlatform == cc.PLATFORM_OS_WINDOWS then
--        self:testCharge(infoTable)
    if GameConfig.targetPlatform == cc.PLATFORM_OS_ANDROID then--下面是 测试代码 模拟一段时间后充值成功
       -- TimerManager:addOnce(3000,self.testSendServerCharge,self,infoTable)
       -- logger:error("测试代码 充值数据：amount:%d, chargeType:%d", amount, chargeType)
       -- self:testSendServerCharge(infoTable)
        if GameConfig.serverId == 9999 then
--             framework.coro.CoroutineManager:startCoroutine(self.delayTestCharge,self, infoTable)
        end
    end
    
end

------------java回调回来-------------------
function sdkChargeOnFinish(result)
    local chargeData = json.decode(result)

    local statusCode = chargeData.statusCode
    local desc = chargeData.desc
    
end
-----------------------------

function SDKManager:delayTestCharge(infoTable)
--    component.SysMessage:show("充值测试,3秒后直接充值成功")
    coroutine.yield(180)
    self:testCharge(infoTable)
end

--直接发送到对应的服务器充值测试 发的是充值钻石
function SDKManager:testSendServerCharge(infoTable)

    local url =  "http://192.168.10.190/gcol/pay.php"
    local params = {}
    
    params["amount"] = infoTable["amount"] / 100
    params["callback_info"] = infoTable["callBackInfo"]
    params["order_id"] = infoTable["productId"]
    params["role_id"] = infoTable["roleId"]
    params["server_id"] = infoTable["serverId"]
    params["status"] = 1
    params["timestamp"] = os.time()
    params["type"] = infoTable["callBackInfo"]--1
    params["user_id"] = 1
    
    local flagStrAry = {}
    table.insert(flagStrAry,params["amount"]) 
    table.insert(flagStrAry,params["callback_info"]) 
    table.insert(flagStrAry,params["order_id"] ) 
    table.insert(flagStrAry,params["role_id"]) 
    table.insert(flagStrAry,params["server_id"]) 
    table.insert(flagStrAry,params["status"]) 
    table.insert(flagStrAry,params["timestamp"]) 
    table.insert(flagStrAry,params["type"]) 
    table.insert(flagStrAry,params["user_id"]) 
    table.insert(flagStrAry,"4872a0d20c60f0906ac4aef9131a4da3")
    
    local flagStr = table.concat(flagStrAry, "#") 
    local sige = AppUtils:calcMD5(flagStr)
    
    params["sign"] = sige
    
    local function sucess(self, data)
        print(":::testSendServerCharge:::::" .. data, flagStr, sige)
        logger:error("data")
        logger:error(data)
        logger:error("flagStr")
        logger:error(flagStr)
        logger:error("sige")
        logger:error(sige)
    end
    for k,v in pairs(params) do
        logger:error(k)
        logger:error(v)
        -- print(k,v)
    end
     
    HttpRequestManager:send(url,params, self, sucess)

--    local server = string.format("http://%s:%d", GameConfig.server, 9978)
--    local url = string.format("%s/change_money?amount=%d&order_id=%s&player_id=%s&callback_info=%s", server,
--        infoTable["amount"] / 100 , 
--        infoTable["productId"],
--        infoTable["roleId"], infoTable["callBackInfo"])
--        
--    local xhr = cc.XMLHttpRequest:new()
--    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
--    xhr:open("GET", url)
--
--    local function onReadyStateChange()
--        if xhr.status == 200 then --接受数据成功
--            local response   = xhr.response
----            if response == "SUCCESS" then
----                component.SysMessage:show("充值测试提示：充值成功")
----            else
----                component.SysMessage:show("充值测试提示：" .. response)
----            end
--        end
--    end
--
--    xhr:registerScriptHandler(onReadyStateChange)
--    xhr:send()
end

function SDKManager:testCharge(infoTable)
    local testUrl = GameConfig.testPayCallbackURL
    local url = string.format("%s?server_id=%s&callback_info=%s&amount=%s&account=%s"
        ,testUrl, tostring(infoTable["serverId"]), tostring(infoTable["callBackInfo"]), tostring(infoTable["amount"] / 100), tostring(infoTable["roleId"]))

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local web_server = GameConfig.web_server
    xhr:open("GET", url)

    local function onReadyStateChange()
        if xhr.status == 200 then --接受数据成功
            local response   = xhr.response
            if response == "SUCCESS" then
--                component.SysMessage:show("充值测试提示：充值成功")
            else
--                component.SysMessage:show("充值测试提示：" .. response)
            end
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function SDKManager:initSDKInfo(info)

    if GameConfig.autoLoginDebug ==  true then
        return
    end
    
    AppUtils:initSDKInfo(info)
end

function SDKManager:showLoginView()

    if GameConfig.autoLoginDebug ==  true then
        return
    end
    
    AppUtils:showLoginView()
end

function SDKManager:showReLogionView()

    if GameConfig.autoLoginDebug ==  true then
        return
    end
    
    AppUtils:showReLogionView()
end

function SDKManager:sdkLogOut()

    if GameConfig.autoLoginDebug ==  true then
        return
    end
    
    AppUtils:sdkLogOut()
end

function SDKManager:initSDKExtendData(userMoney)

    if GameConfig.autoLoginDebug ==  true then
        return
    end
    
    local infoTable = {}
    local roleName = tostring(GameConfig.actorName)
    if roleName == "" then
        roleName = "不存在"
        return --没有创建角色，则不发送统计数据
    end
    if GameConfig.roleCreateTime == 0 then
        return --没有创建时间就不统计了
    end
    infoTable["roleId"] = StringUtils:fixed64ToNormalStr(GameConfig.actorid)
    infoTable["roleName"] = roleName
    infoTable["roleLevel"] = tostring(GameConfig.level)
    infoTable["serverId"] = GameConfig.serverId
    infoTable["serverName"] = GameConfig.serverName
    infoTable["vipLevel"] = tostring(GameConfig.vipLevel)
    infoTable["userMoney"] = tostring(userMoney)
    infoTable["serverTime"] = math.ceil(GameConfig.serverTime)
    infoTable["roleCreateTime"] = GameConfig.roleCreateTime
    
--    require("json")
--    local infoJson = json.encode(infoTable)
    AppUtils:initSDKExtendData(infoTable)
end

function SDKManager:sendExtendDataRoleCreate(userMoney)

    if GameConfig.autoLoginDebug ==  true then
        return
    end
    
    local infoTable = {}
    infoTable["roleId"] = StringUtils:fixed64ToNormalStr(GameConfig.actorid)
    infoTable["roleName"] = tostring(GameConfig.actorName)
    infoTable["roleLevel"] = tostring(GameConfig.level)
    infoTable["serverId"] = GameConfig.serverId
    infoTable["serverName"] = GameConfig.serverName
    infoTable["vipLevel"] = tostring(GameConfig.vipLevel)
    infoTable["userMoney"] = tostring(userMoney)
    infoTable["serverTime"] = math.ceil(GameConfig.serverTime)
    infoTable["roleCreateTime"] = GameConfig.roleCreateTime
    
--    require("json")
--    local infoJson = json.encode(infoTable)
    AppUtils:sendExtendDataRoleCreate(infoTable)
end

function SDKManager:sendExtendDataRoleLevelUp(userMoney)
    if GameConfig.autoLoginDebug ==  true then
        return
    end

    local infoTable = {}
    infoTable["roleId"] = StringUtils:fixed64ToNormalStr(GameConfig.actorid)
    infoTable["roleName"] = tostring(GameConfig.actorName)
    infoTable["roleLevel"] = tostring(GameConfig.level)
    infoTable["serverId"] = GameConfig.serverId
    infoTable["serverName"] = GameConfig.serverName
    infoTable["vipLevel"] = tostring(GameConfig.vipLevel)
    infoTable["userMoney"] = tostring(userMoney)
    infoTable["serverTime"] = math.ceil(GameConfig.serverTime)
    infoTable["roleCreateTime"] = GameConfig.roleCreateTime

--    require("json")
--    local infoJson = json.encode(infoTable)
    AppUtils:sendExtendDataRoleLevelUp(infoTable)
end

function SDKManager:canShowFloatIcon(flag)
    AppUtils:canShowFloatIcon(flag)
end

function SDKManager:showWebHtmlView(url)
    local isHttpReq = string.find(url,"http://")
    if isHttpReq == nil then
        url = GameConfig.web_help_url .. url
    end
    AppUtils:showWebHtmlView(url)
end

--打开语音面板
function SDKManager:showASRDigitalDialog()
    AppUtils:showBaiduASRDigitalDialog()
end

--关闭语音面板--完成一次录音
function SDKManager:hideASRDigitalDialog()
    AppUtils:hideBaiduASRDigitalDialog()
end

--取消语音 关闭面板
function SDKManager:cancelASRDigitalDialog()
    AppUtils:cancelBaiduASRDigitalDialog()
end

function SDKManager:setMaxRecorderTime(maxTime)
    AppUtils:setMaxRecorderTime(maxTime)
end

--获取账号校验码
function SDKManager:getAccountSign(account, areId)
    local value = account .. "_" .. areId .. "_" .. "~~~~~@@@@@@@@@$@*&!!znl~~~~~~~~~"
    local xxhash = AppUtils:calcXXHash(value, 0x9747b28c)
    return xxhash
end

--退出APP
function SDKManager:exitApp()
    AppUtils:exitApp()
end

--是否SDK初始化完毕
function SDKManager:isInitSDKFinish()
    return AppUtils:isInitSDKFinish()
end

--重登是否打开了SDK登录框
function SDKManager:isReLoginView()
    return AppUtils:isReLoginView()
end

--设置帧率
function SDKManager:setAnimationInterval(interval)
    AppUtils:setAnimationInterval(interval)
    cc.Director:getInstance():setAnimationInterval(1.0 / interval)
end

--设置push tags
function SDKManager:setPushTags(tags)
    require("json")
    local tagsJson = json.encode(tags)
    AppUtils:setPushTags(tagsJson)

end

-----------设置是否可以多点触控
function SDKManager:setMultipleTouchEnabled(enabled)

    if self._multipleTouchEnabled == enabled then
        return
    end
    self._multipleTouchEnabled = enabled
    AppUtils:setMultipleTouchEnabled(enabled)
    -- print("!!!!!!!!!!!setMultipleTouchEnabled!!!!!!!!!!", enabled)
end

--点击url链接跳转
function SDKManager:openURL(url)
    AppUtils:openURL(url)
end

function SDKManager:gameLogout()
    AppUtils:gameLogout()
end

-- 前往客服中心
-- 客户端点击前往官网 ---> 请求中转服务器 --> 中转服务器获取客户端上传的数据进行计算请求gmapi接口-->校验成功中转服务器则跳转地址
function SDKManager:openGMCenter()
    local game_id = tostring(GameConfig.game_Id) --游戏id
    local server_id = GameConfig.serverId --服id
    local role_id = StringUtils:fixed64ToNormalStr(GameConfig.actorid)  --角色id
    local role_name = tostring(GameConfig.actorName)  --角色名
    local server_name = GameConfig.serverName  --服名
    local level = tostring(GameConfig.level)  --角色等级
    local vip_lv = tostring(GameConfig.vipLevel)  --vip等级
    local source = tostring(1)  --固定值，3K客服平台提供
    local from_id = tostring(GameConfig.platformChanleId)  --渠道id

    -- IOS里面渠道号直接传0
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform or 
    cc.PLATFORM_OS_IPAD == targetPlatform then
        from_id = "0"
    end
    
    -- local url = GameConfig.local_admincenter_api_url  -- 中央服地址
    -- url = url .. "?source=%s&role_name=%s&server_name=%s&level=%s&vip_lv=%s&server_id=%s&role_id=%s&from_id=%s&service=Contact.GetContact"
    -- url = string.format( url, source, role_name, server_name, level, vip_lv, server_id, role_id, from_id )

    source = self:urlEncode(source)
    role_name = self:urlEncode(role_name)
    server_name = self:urlEncode(server_name)
    level = self:urlEncode(level)
    vip_lv = self:urlEncode(vip_lv)
    server_id = self:urlEncode(server_id)
    role_id = self:urlEncode(role_id)
    from_id = self:urlEncode(from_id)

    local url = "?source=%s&role_name=%s&server_name=%s&level=%s&vip_lv=%s&server_id=%s&role_id=%s&from_id=%s&service=Contact.GetContact"
    url = string.format( url, source, role_name, server_name, level, vip_lv, server_id, role_id, from_id )

    url = GameConfig.admincenter_api_url .. url  -- 中央服地址
    -- logger:error("前往客服中心 1 :%s",url)


    -- 安卓旧版本客服中心用openURL跳转外链
    if GameConfig.targetPlatform == cc.PLATFORM_OS_ANDROID then
        local mainVersion = GameConfig.mainVersion
        local version = GameConfig.localVersion
        if mainVersion < 11 and version < 20 then
            self:openURL(url)
            return
        end
    end

    self:showWebHtmlView(url)
end

function SDKManager:showSelectPicUpload(infoJson)
    AppUtils:showSelectPicUpload(infoJson)
end

function SDKManager:downloadHeadPic(headInfo)
    AppUtils:downloadHeadPic(headInfo)
end

-- 编码
function SDKManager:urlEncode(s)  
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end  

-- 解码
function SDKManager:urlDecode(s)  
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)  
    return s  
end

