LoginPanel = class("LoginPanel", BasicPanel,FriendProxy)

LoginPanel.NAME = "LoginPanel"

function LoginPanel:ctor(view, panelName)
    LoginPanel.super.ctor(self, view, panelName)
end

function LoginPanel:finalize()
    if self._model ~= nil then
        self._model:finalize(false)
    end

    -- local panel = self._mainPanel  --测试崩溃用的
    -- local schedule = nil
    -- local function update()
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedule)
    --     UICCBLayer.new("rgb-piantou-kaiji2", panel)
    --     panel:setPosition(0, 0)
    -- end
    -- schedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 30 / 1000 ,false)
    LoginPanel.super.finalize(self)
end

function LoginPanel:initPanel()
    LoginPanel.super.initPanel(self)
    
    local mainPanel = self:getChildByName("mainPanel")
    self._mainPanel = mainPanel
--    local bg = TextureManager:createImageViewFile("bg/login/Scenes" .. TextureManager.bg_type)
--    bg:setAnchorPoint(cc.p(0, 0)) --TODO记得释放
--    NodeUtils:adaptiveXCenter(bg)
--    mainPanel:addChild(bg)

    local x, y = NodeUtils:getCenterPosition()
    local layer = UICCBLayer.new("rgb-piantou-kaiji", mainPanel)
    layer:setPosition(x, y * 2 - 1138 / 2)

    local layer = UICCBLayer.new("rgb-piantou-logo", mainPanel) 
    layer:setPosition(x, y * 2 - 250 / 2 - 45)
    
    -- local root = self:getPanelRoot()
    -- local model = SpineModel.new(9999, root)
    -- model:playAnimation("animation", true)
    -- model:setLocalZOrder(4)
    -- NodeUtils:adaptiveXCenter(model, cc.size(640,1000))
    -- self._model = model
    
    -- 勾选接受PK玩法
    self._checkBox = self:getChildByName("pkPanel/checkBox")
    self._checkBox:setSelectedState(true)
    local infoTxt = self:getChildByName("pkPanel/infoTxt")
    infoTxt:setString(self:getTextWord(213))
    NodeUtils:enableShadow(infoTxt)
    

    local versionTxt = self:getChildByName("versionTxt")
    versionTxt:setString(string.format(self:getTextWord(116), VersionManager:getVersionStr()))

    local isbnTxt = self:getChildByName("isbnTxt")
    isbnTxt:setString(VersionManager:getISBNName())

    local warnTxt = self:getChildByName("warnTxt")
    warnTxt:setString(self:getTextWord(132))

    --NodeUtils:enableShadow(versionTxt)
    --NodeUtils:enableShadow(isbnTxt)
    --NodeUtils:enableShadow(warnTxt)
    
    --3k渠道才有这个功能
    if GameConfig.platformChanleId == 0 or GameConfig.platformChanleId == -1 then
        -- self:addTouchEventListener(versionTxt, self.onVersionTxtTouch, nil, nil, nil, nil,nil, true) 
    end
    
    GlobalConfig:preLoadImage()
    
--    if ccexp.VideoPlayer ~= nil then
--        local videoPlayer = nil
--        local function onVideoEventCallback(sener, eventType)
----            if eventType == ccexp.VideoPlayerEvent.PLAYING then
----            elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
----            elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
----            elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
----                if videoPlayer ~= nil then
----                    videoPlayer:play()
----                end
----            end
--            logger:error("==========VideoPlayer==============" .. eventType)
--            self:showSysMessage("...click..." .. eventType)
--        end
--
--        local function callback()
--            videoPlayer = ccexp.VideoPlayer:create()
--            videoPlayer:setContentSize(cc.size(640, 1000))
----            videoPlayer:setAnchorPoint(0, 0)
--
--            videoPlayer:setFileName("res/video/cg.mp4")
--            videoPlayer:play()
----            videoPlayer:setPosition(100,100)
--            videoPlayer:setLocalZOrder(4)
--            videoPlayer:addEventListener(onVideoEventCallback)
--            videoPlayer:setTouchEnabled(false)
--            
----            videoPlayer:se
--            local modelPanel = self:getChildByName("modelPanel")
--            local scale = 1 / NodeUtils:getAdaptiveScale()
--            modelPanel:setPosition(320 * scale, 500 * NodeUtils:getAdaptiveScale())
--            
--            modelPanel:addChild(videoPlayer)
--        end
--
--        TimerManager:addOnce(30,callback,self)
--        
--        local function playVideo()
--            if videoPlayer ~= nil then
--                videoPlayer:play()
--            end
--        end
--        TimerManager:addOnce(60,playVideo,self)
--    end
    
    local inputPanel = self:getChildByName("inputPanel")
    self._editBox = ComponentUtils:addEditeBox(inputPanel, 10, self:getTextWord(202), nil, false, "images/login/Bg_log.png")
    
    if GameConfig.targetPlatform ~= cc.PLATFORM_OS_WINDOWS and GameConfig.autoLoginDebug ~= true then
        self._editBox:setVisible(false)
        inputPanel:setVisible(false)
    else
        local lastLoginAccount =  self:getLocalData("lastLoginAccount", true)
        self._editBox:setText(lastLoginAccount)
        GameConfig.accountName = lastLoginAccount
--        self._editBox:setFontName("DroidSansFallback")
--        self._editBox:setPlaceholderFontSize(18)
    end
    
    self._isSetServerInfo = false

    self._touchDirStr = ""
    self._openStr = "→→←←←←→→→←"

end

function LoginPanel:toChangePackageInfo(sender, packageInfo, isTest)
    packageInfo = packageInfo or 1
    isTest = isTest or 2
    local action1 = cc.ScaleTo:create(0.5,2)
    local action2 = cc.ScaleTo:create(0.5,1)
    local action = cc.Sequence:create(action1, action2)
    sender:runAction(action)
    
    --换成包内从，重新请求
    GameConfig:setPackageInfo(packageInfo)
    GameConfig.isTest = isTest
    if packageInfo == 1 then
        cc.Director:getInstance():setDisplayStats(true)
    end
    
    self:dispatchEvent(LoginEvent.GET_SERVER_LIST, {})

    -- --更新version.lua
    -- local cdn_host = GameConfig.version_head_url .. "testModule/version.lua"  --cdn更新路径
    -- local function versioncb(obj, data)  --为了处理，可以测试，中版本的热更内容
    --     VersionManager:loadServerVersion(data)
    -- end
    -- HttpRequestManager:send(cdn_host, {}, self, versioncb )

end

function LoginPanel:onVersionTxtTouch(sender)
--    "203.195.140.103,8080,1,S2-真●外网测试服,1,9901"
    --14.18.236.69,8080,1,S1-内网测试服,1,9993

    --再有的话，就删除掉了
    TimerManager:remove(self.toChangePackageInfo, self)

    if sender.index == nil then
        sender.index = 1
    else
        sender.index = sender.index + 1
    end
    
    if sender.index == 10 then  --点击10次
        TimerManager:addOnce(1000, self.toChangePackageInfo, self, sender, 2, 3)
    elseif sender.index == 20 then
        TimerManager:addOnce(1000, self.toChangePackageInfo, self, sender, 1, 1)
    elseif sender.index == 30 then
        sender.index = 1 --还原
    end
end

--------------------
function LoginPanel:setSelectedServerInfo(serverInfo)
    local selectTxt = self:getChildByName("serverInfoBtn/selectTxt")
    selectTxt:setString(serverInfo.name)
    NodeUtils:enableShadow(selectTxt)
    
    GameConfig.server = serverInfo.ip
    GameConfig.port = serverInfo.port
    GameConfig.serverName = serverInfo.name
    GameConfig.serverArea = serverInfo.area
    GameConfig.serverId = tonumber(serverInfo.serverId)
    GameConfig.serverState = tonumber(serverInfo.state)
    GameConfig.isPre = serverInfo.isPre --true --
    
    local state = tonumber( serverInfo.state)
    local stateTxt = self:getChildByName("serverInfoBtn/stateTxt")
    stateTxt:setString(self:getTextWord(280 + state))

    local color = ColorUtils:getColorByState(state)
    stateTxt:setColor(color)
    
    self._lastServerInfo = serverInfo
    
    self._isSetServerInfo = true
end

function LoginPanel:getLastServerInfo()
    return self._lastServerInfo
end

function LoginPanel:getUserName()
    local name = self._editBox:getText()
    return name
end

-----------------------
function LoginPanel:registerEvents()
    local mainPanel = self:getChildByName("mainPanel")


    self:addTouchEventListener(mainPanel, self.endPanelTouch, nil, nil, nil, nil,nil, true) 
    
    local serverInfoBtn = self:getChildByName("serverInfoBtn")
    self:addTouchEventListener(serverInfoBtn, self.onOpenServerListPanelTouch)

    local loginBtn = serverInfoBtn:getChildByName("loginBtn")
    self:addTouchEventListener(loginBtn, self.onLoginBtnTouch)
    -- loginBtn:setTouchEnabled(false)
    -- self:addTouchEventListener(mainPanel, self.onLoginBtnTouch)

    
    local scaleDelay = 30/40                            --时长(游戏设计40帧/秒)
    local action1 = cc.ScaleTo:create(scaleDelay,0.9)   --1.0缩小到0.9
    local action2 = cc.ScaleTo:create(scaleDelay,1.0)   --0.9放大到1.0
    local seq = cc.Sequence:create(action1, action2, nil)
    -- loginBtn:runAction(cc.RepeatForever:create(seq))


    
end

function LoginPanel:endPanelTouch(sender, value, dir)

    local dirStr = ""
    if dir == 1 then
        dirStr = "→"
    else
        dirStr = "←"
    end
    self._touchDirStr = self._touchDirStr .. dirStr

    TimerManager:remove(self.toChangePackageInfo, self)

    if sender.index == nil then
        sender.index = 1
    else
        sender.index = sender.index + 1
    end
    
    if sender.index == 10 then  --点击10次
        --进行校验
        if self._openStr == self._touchDirStr then
            TimerManager:addOnce(1000, self.toChangePackageInfo, self, sender, 2, 3)
        end
    elseif sender.index == 20 then
        GlobalConfig.chatMinLv = 1
        if self._openStr .. self._openStr == self._touchDirStr then
            TimerManager:addOnce(1000, self.toChangePackageInfo, self, sender, 1, 1)
        end
    elseif sender.index >= 30 then
        self._touchDirStr = ""
        sender.index = 1 --还原
    end
end

function LoginPanel:onLoginBtnTouch(sender)
    if GameConfig.serverState == 3 then --服务器状态，正在维护中
        self:showSysMessage(self:getTextWord(117))
        return
    end

    if self._isSetServerInfo ~= true then
        self:showSysMessage(self:getTextWord(118))
        return
    end

    if self._checkBox:getSelectedState() ~= true then
        self:showSysMessage(self:getTextWord(214))
        return
    end

    if GameConfig.serverState == 4 then  --服务器即将开服
        local openTime = self._lastServerInfo.openTime or 0
        local str = TimeUtils:setTimestampToString4(openTime)
        local content = string.format(self:getTextWord(119), str)
        self:showSysMessage(content)
        return
    end

    self.view:onLoginReq({})
end

function LoginPanel:onOpenServerListPanelTouch(sender)
    if self._lastServerInfo == nil then
        return
    end
    self.view:onShowServerListPanel()
end

