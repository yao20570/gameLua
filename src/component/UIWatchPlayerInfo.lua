UIWatchPlayerInfo = class("UIWatchPlayerInfo")

--isMap  从map模块调用进来，要特殊处理
function UIWatchPlayerInfo:ctor(parent, panel, isViewShow, isRank, isMap)
    local uiSkin = UISkin.new("UIWatchPlayerInfo")
    uiSkin:setParent(parent)
    self._isRank = isRank
    self._data = {}
    self._panel = panel
    self._uiSkin = uiSkin
    self._uiSkin:setLocalZOrder(5)
    self._uiSkin:setVisible(isViewShow)
    self.isFromWorldMap = false  
    self._offsetX = 12
    self._isMap = isMap

    self._moveChild = {"lv", "name", "power", "solidier", "coord", "lvTxt", "powerTxt", "solidierTxt", "coordTxt", "vipImg", "vipLab"}

    -- local secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self)
    -- secLvBg:setContentHeight(430)
    -- secLvBg:setTitle(TextWords:getTextWord(506))

    --[[
    new一个二级背景,将messageBox的全部子节点clone到二级背景下，
    再删除messageBox的全部子节点    
    ]]
    --begin-------------------------------------------------------------------
    if self.secLvBg == nil then
        local secLvBg = UISecLvPanelBg.new(self._uiSkin:getRootNode(), self)
        secLvBg:setContentHeight(390)
        secLvBg:setTitle(TextWords:getTextWord(506))
        secLvBg:setBackGroundColorOpacity(120)
        self.secLvBg = secLvBg
        -- secLvBg:hideCloseBtn(false)
        -- secLvBg:setLocalZOrder(self._localZOrder)

        local oldPanel = uiSkin:getChildByName("Panel_30")
        local mainPanel = secLvBg:getMainPanel()
        local panel = oldPanel:clone()
        panel:setName("panel")
        mainPanel:addChild(panel)
        self.mainPanel = panel
        oldPanel:setVisible(false)
        oldPanel:removeFromParent()
    end
    --end-------------------------------------------------------------------
    

    self:registerEvents()

end

function UIWatchPlayerInfo:finalize()
    if self._uiSharePanel ~= nil then
       self._uiSharePanel:finalize()
       self._uiSharePanel = nil 
    end
    local chatProxy = self._panel:getProxy(GameProxys.Chat)
    -- chatProxy:removeEventListener(AppEvent.CLEAR_TOOLBAR_CMD, self, self.hide)
    self._uiSkin:finalize()
    self._uiSkin = nil
end

function UIWatchPlayerInfo:showAllInfo( data )
    self.data = data
    self.isFromWorldMap = false
    self._uiSkin:setVisible(true)
    
    self._nameTxt = self.mainPanel:getChildByName("name")
    self._vipImg = self.mainPanel:getChildByName("vipImg")
    self._vipLab = self.mainPanel:getChildByName("vipLab")
    self._lv = self.mainPanel:getChildByName("lv")
    self._lvTxt = self.mainPanel:getChildByName("lvTxt")
    self._powerTxt = self.mainPanel:getChildByName("powerTxt")
    self._solidierTxt = self.mainPanel:getChildByName("solidierTxt")
    self._coordTxt = self.mainPanel:getChildByName("coordTxt")
    self._bgImg = self.mainPanel:getChildByName("Bg")

    local power = self.mainPanel:getChildByName("power")
    local solidier = self.mainPanel:getChildByName("solidier")
    local coord = self.mainPanel:getChildByName("coord")
    power:setString(TextWords:getTextWord(136))
    solidier:setString(TextWords:getTextWord(137))
    coord:setString(TextWords:getTextWord(138))
    
    local ProgressBarBg
    if self._isMap ~= nil then
        self._loadingNumBar = self.spcPanel:getChildByName("loadingNumBar")
        ProgressBarBg = self.spcPanel:getChildByName("ProgressBarBg")
    else
        self._loadingNumBar = self.norPanel:getChildByName("loadingNumBar")
        local Image_9 = self.norPanel:getChildByName("Image_9")
        ProgressBarBg = self.norPanel:getChildByName("ProgressBarBg")
        self._loadingNumBar:setVisible(false)
        Image_9:setVisible(false)
        ProgressBarBg:setVisible(false)
    end
    self._ProgressBar = ProgressBarBg:getChildByName("ProgressBar")


    
    local tileInfo = rawget(data, "tileInfo")
    self:showInfo(data.info, tileInfo)
end

function UIWatchPlayerInfo:setLocalZOrder(order)
    self._uiSkin:setLocalZOrder(order)
end

function UIWatchPlayerInfo:showInfo(data, tileInfo)
    self._tileInfo = tileInfo
    -- body
--------------------------yyyy
    self._headImg = self.norPanel:getChildByName("actorBg")
    
    local pendantId = nil
    if data.pendantId == nil then
        pendantId = 0
    else
        pendantId = data.pendantId
    end

    local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = pendantId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    headInfo.isCreatButton = false
    headInfo.playerId = rawget(data, "playerId")

    local head = self._head
    if head == nil then
        head = UIHeadImg.new(self._headImg,headInfo,self)
        
        self._head = head
    else
        head:updateData(headInfo)
    end
    head:showHeadBg(true)
    local mrConfigInfo = ConfigDataManager:getConfigById(ConfigData.MilitaryRankConfig,data.militaryRank)
    local rankTxt = self.norPanel:getChildByName("rank")
    rankTxt:setString(mrConfigInfo.name)
    
--------------------------yyyy
    self._nameTxt:setString(data.name)

    
    self._lvTxt:setString(data.level)

    self._vipLab:setVisible(data.vipLv ~= 0 and data.vipLv ~= nil)
    self._vipImg:setVisible(data.vipLv ~= 0 and data.vipLv ~= nil)
    self._vipLab:setString(data.vipLv)

    self._lvTxt:setPositionX(self._lv:getPositionX() + self._lv:getContentSize().width + 3)
    NodeUtils:alignNodeL2R(self._lvTxt, self._nameTxt, self._vipImg, self._vipLab, 10)
--    self._vipImg:setPositionX(self._nameTxt:getPositionX()+self._nameTxt:getContentSize().width+10)
--    self._vipLab:setPositionX(self._vipImg:getPositionX()+self._vipImg:getContentSize().width)


    -- self._powerTxt:setString(data.capacity)
    self._powerTxt:setString(StringUtils:formatNumberByK3(data.capacity, nil))
    self._solidierTxt:setString(data.legion)

    -- 繁荣
    self._loadingNumBar:setString(data.boom.."/"..data.boomUpLimit)
    local per = 0
    if data.boom >= data.boomUpLimit then
        per = 100
    else
        per = data.boom/data.boomUpLimit * 100
    end
    self._ProgressBar:setPercent(per)
    -- self._ProgressBar:setPercent(4)

    self._legionBtn:setVisible(false)
    self._sceneBtn:setVisible(false)
    
    self._addFriendBtn:setVisible(true)
    self._writeBtn:setVisible(true)
    self._privateChatBtn:setVisible(true)
    local btn1 = self.mainPanel:getChildByName("addFriendBtn")
    local btn2 = self.mainPanel:getChildByName("shieldBtn")
    local btn3 = self.mainPanel:getChildByName("privateChatBtn")
    local btn4 = self.mainPanel:getChildByName("writeBtn") 
    local btn5 = self.mainPanel:getChildByName("reportBtn")  --举报
    local btns = {btn1, btn4, btn3, btn2}
    local panel = self.mainPanel:getChildByName("Panel_1")
    panel:setVisible(false)
    btn5:setVisible( false )
    if self._isRank ~= nil then
        -- 排行榜
        panel:setVisible(true)
        self._coordTxt:setString(TextWords:getTextWord(308))
        self._collectBtn:setVisible(false)
        self._attackBtn:setVisible(false) 
        self._spyBtn:setVisible(false)
        btn2:setVisible(false)
--        self._bgImg:setContentSize(cc.size(580,405))
--        self._bgImg:setPosition(320, 496)
        if self._isRank == true then
            btn1:setVisible(false)
            btn3:setVisible(false)
            btn4:setVisible(false)
            panel:setVisible(true)
        else
            btn1:setVisible(true)
            btn3:setVisible(true)
            btn4:setVisible(true)
            panel:setVisible(false)
        end

    elseif tileInfo == nil then
        -- 聊天等
        self._coordTxt:setString(TextWords:getTextWord(308))
        self._collectBtn:setVisible(false)
        self._attackBtn:setVisible(false) 
        self._spyBtn:setVisible(false)
        btn2:setVisible(true)

        --显示举报按钮 -- edited by fwx 2016.10.13
        if self._panel.tabControl then
            local panelName = self._panel.tabControl:getCurPanelName()
            if panelName=="WorldChatPanel" or panelName=="ChatPrivatePanel" then
                btn5:setVisible(true)
                -- table.insert( btns, btn5)
            end
        end
--        self._bgImg:setContentSize(cc.size(580,405))
--        self._bgImg:setPosition(320, 496)
    else
        -- 世界地图
        self.isFromWorldMap = true
        self._coordTxt:setString("(" .. tileInfo.buildingInfo.x .. "/" .. tileInfo.buildingInfo.y ..")")
        local roleProxy = self._panel:getProxy(GameProxys.Role)
        local worldTileX, worldTileY = roleProxy:getWorldTilePos()
        local isHaveLegion = roleProxy:hasLegion()
        --在世界地图查看自己
        if worldTileX == tileInfo.buildingInfo.x and worldTileY == tileInfo.buildingInfo.y then
            self._collectBtn:setVisible(false)
            self._attackBtn:setVisible(false) 
            self._spyBtn:setVisible(false)
            btn1:setVisible(false)
            btn2:setVisible(false)
            btn3:setVisible(false)
            btn4:setVisible(false)
            
            if isHaveLegion == true then
                self._legionBtn:setVisible(true)
                NodeUtils:setEnable(self._legionBtn, true)
            else
                self._legionBtn:setVisible(true)
                NodeUtils:setEnable(self._legionBtn, false)
            end
            self._sceneBtn:setVisible(true)
            
            --TODO 还需要判断自己是否有军团
            
--            self._bgImg:setContentSize(cc.size(580,405))
--            self._bgImg:setPosition(320, 496)
        else
            self._collectBtn:setVisible(true)
            self._attackBtn:setVisible(true) 
            self._spyBtn:setVisible(true)
            btn1:setVisible(true)
            btn2:setVisible(false)
            btn3:setVisible(true)
            btn4:setVisible(true)
--            self._bgImg:setContentSize(cc.size(580,503))
--            self._bgImg:setPosition(320, 450)
            if isHaveLegion then
                local isSameLegion = false
                local myLegionName = roleProxy:getLegionName()
                if myLegionName ~= nil and data.legion ~= nil and myLegionName == data.legion then
                    isSameLegion = true
                end
                if isSameLegion then
                    self.isAttack = false
                    self._attackBtn:setTitleText(TextWords:getTextWord(111))
                else
                    self.isAttack = true
                    self._attackBtn:setTitleText(TextWords:getTextWord(732))
                end
            else
                self.isAttack = true
                self._attackBtn:setTitleText(TextWords:getTextWord(732))
            end
        end
        --外观建筑
    end
    local y = self._spyBtn:isVisible() and 376 or 350
    if btn2:isVisible() then
        -- local x = 640/(#btns+1) --加一个举报按钮 -- edited by fwx 2016.10.13
        for k,v in pairs(btns) do
            v:setPosition(116+(k-1)*136, y)
        end
    else
        for k,v in pairs(btns) do
            v:setPosition(128+(k-1)*192, y)
        end
    end

    

    local Image_9 = self.norPanel:getChildByName("Image_9")
    if self._isMap ~= nil then
       Image_9 = self.spcPanel:getChildByName("Image_9") 
    end
    local cityIcon = Image_9:getChildByName("Image_10")
    local myNumIcon = data.cityIcon
    local url = ComponentUtils:getWorldBuildingUrl(myNumIcon)
    TextureManager:updateImageView(cityIcon,url)
    -- cityIcon:setScale(1.25) --屏蔽
    
    self._Id = data.playerId
    
    local friendProxy = self._panel:getProxy(GameProxys.Friend)
    local isFriend = friendProxy:isFriend(data.playerId)
    if isFriend == true then
        self._addFriendBtn:setTitleText(TextWords:getTextWord(1109))
    else
        self._addFriendBtn:setTitleText(TextWords:getTextWord(1105))
    end
    
    self._addFriendBtn.isFriend = isFriend
end
function UIWatchPlayerInfo:registerEvents()
    -- body
    -- self._oncloseBtn = self.mainPanel:getChildByName("closeBtn")
    self._shieldBtn = self.mainPanel:getChildByName("shieldBtn")
    self._collectBtn = self.mainPanel:getChildByName("collectBtn") 
    self._attackBtn = self.mainPanel:getChildByName("attackBtn") 
    self._spyBtn = self.mainPanel:getChildByName("spyBtn") 
    self._legionBtn = self.mainPanel:getChildByName("legionBtn") 
    self._sceneBtn = self.mainPanel:getChildByName("sceneBtn")
    self._reportBtn = self.mainPanel:getChildByName("reportBtn")
    -- ComponentUtils:addTouchEventListener(self._oncloseBtn, self.onClickEvents, nil, self)
    ComponentUtils:addTouchEventListener(self._shieldBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._collectBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._attackBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._spyBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._legionBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._sceneBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._reportBtn, self.onClickEvents, nil , self)
    self._shieldBtn:setVisible(false)

    if self._isRank == nil or self._isRank == false then
        self._addFriendBtn = self.mainPanel:getChildByName("addFriendBtn")
        self._writeBtn = self.mainPanel:getChildByName("writeBtn") 
        self._privateChatBtn = self.mainPanel:getChildByName("privateChatBtn")
    else
        local Panel_1 = self.mainPanel:getChildByName("Panel_1")
        self._addFriendBtn = Panel_1:getChildByName("addFriendBtn")
        self._writeBtn = Panel_1:getChildByName("writeBtn") 
        self._privateChatBtn = Panel_1:getChildByName("privateChatBtn")
    end
    ComponentUtils:addTouchEventListener(self._addFriendBtn, self.onClickEvents, nil, self)
    ComponentUtils:addTouchEventListener(self._writeBtn, self.onClickEvents, nil , self)
    ComponentUtils:addTouchEventListener(self._privateChatBtn, self.onClickEvents, nil ,self)

    self.spcPanel = self.mainPanel:getChildByName("spcPanel")
    self.spcPanel:setVisible(self._isMap ~= nil)
    self.norPanel = self.mainPanel:getChildByName("norPanel")
    self.norPanel:setVisible(self._isMap == nil)

    local shareBtn = self.spcPanel:getChildByName("shareBtn")
    ComponentUtils:addTouchEventListener(shareBtn, self.onShare, nil ,self)

    for k,v in pairs(self._moveChild) do
        local child = self.mainPanel:getChildByName(v)
        child.x = child.x or child:getPositionX()
        if self._isMap then
            child:setPositionX(child.x + self._offsetX)
        else
            child:setPositionX(child.x)
        end
    end

    local chatProxy = self._panel:getProxy(GameProxys.Chat)
    --20000的时候发了一个事件出来，接收到就直接隐藏
    -- chatProxy:addEventListener(AppEvent.CLEAR_TOOLBAR_CMD, self, self.hide)
end
function UIWatchPlayerInfo:onAddFriendResp(isFriend)
    local friendProxy = self._panel:getProxy(GameProxys.Friend)
    
    if isFriend == true then --是好友，则请求删除好友
        friendProxy:removeFriendReq(self._Id)
    else
        friendProxy:addFriendReq(self._Id)
    end
end

------
-- 消息发送，type//0:邮件，1：聊天
function UIWatchPlayerInfo:onShieldResp()
    local chatProxy = self._panel:getProxy(GameProxys.Chat)
    print("self._mailShield===",self._mailShield)
    if self._mailShield ~= nil then
        chatProxy:onShieldPlayerReq(0,self._Id)
        self._mailShield = nil
    else
        chatProxy:onShieldPlayerReq(1,self._Id)
    end
end

function UIWatchPlayerInfo:setMialShield(mailShield)
    self._mailShield = mailShield
end

function UIWatchPlayerInfo:onClickEvents( sender )
	-- body
    -- if sender == self._oncloseBtn then   --关闭页面
        -- self._uiSkin:setVisible(false)
    if sender == self._addFriendBtn then    --添加或删除好友
        self:onAddFriendResp(self._addFriendBtn.isFriend)
    elseif sender == self._shieldBtn then  --屏蔽
        self:onShieldResp()
    elseif sender == self._reportBtn then  --举报
        local channelType = 0
        if self._panel.tabControl and self._panel.tabControl:getCurPanelName()=="WorldChatPanel" then
            channelType = 1
        end
        local data = {}
        data["moduleName"] = ModuleName.ReportModule
        data["extraMsg"] = {}
        data["extraMsg"]["channelType"] = channelType
        data["extraMsg"]["playerId"] = self.data.info.playerId or 0
        data["extraMsg"]["playerName"] = self.data.info.name or ""
        self._panel:dispatchEvent(ChatEvent.SHOW_OTHER_EVENT, data)
    elseif sender == self._privateChatBtn then--私聊
        local isFromRank = self._isRank
        self._mailShield = nil
        local data = self.data
        local chatProxy = self._panel:getProxy(GameProxys.Chat)
        data.index = 0
        data.isFromWorldMap = self.isFromWorldMap
        if isFromRank == nil or isFromRank == false then
            data.isFromRank = false
        else
            data.isFromRank = true
        end
        chatProxy:enterPrivate(data)
    elseif sender ==  self._writeBtn then   --写信
        local roleProxy = self._panel:getProxy(GameProxys.Role)
        local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        if lv < GlobalConfig.chatMinLv then
            roleProxy:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
            return
        end

        local nameContext = self.data.info.name
        local data = {}
        if self._mailShield == true then --已经在邮件模块里面
            data.name = nameContext
            data.type = "writeMail"
        else   
            data["moduleName"] = ModuleName.MailModule
            data["extraMsg"] = {}
            data["extraMsg"]["type"] = "writeMail"
            data["extraMsg"]["isCloseModule"] = true
            data["extraMsg"]["name"] = nameContext --你要写给对方的名字
        end
        self._mailShield = nil
        local chatProxy = self._panel:getProxy(GameProxys.Chat)
        chatProxy:enterWriteMsg(data)
    elseif sender == self._collectBtn then  --收藏
        if self._tileInfo ~= nil then
            self._tileInfo.playerInfo = self.data.info --玩家信息
            self._panel:onPlayerCollectTouch(self._tileInfo)
        end
    elseif sender == self._attackBtn then  --攻击
        if self.isAttack then
            self._panel:onAttackPlayerTouch(self._tileInfo)
        else
            self._panel:onGoStationTouch(self._tileInfo)
        end
        
    elseif sender == self._spyBtn then --侦查
        self._panel:onSpyPriceTouch(self._tileInfo)
    elseif sender == self._sceneBtn then --回到场景
        self._panel:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.MainSceneModule})
    elseif sender == self._legionBtn then --进入军团基地
        self._panel:dispatchEvent(MapEvent.SHOW_OTHER_EVENT, {moduleName = ModuleName.LegionSceneModule})
    end
    self._uiSkin:setVisible(false)
    self._mailShield = nil

    if self._uiSharePanel ~= nil then
        if self._uiSharePanel:isVisible() == true then
            self._uiSharePanel:hidePanel()
        end
    end
end

function UIWatchPlayerInfo:hide()
    if self._uiSkin == nil then
        return
    end
    if self._uiSkin.root ~= nil and tolua.isnull(self._uiSkin.root) then
        return
    end
    if self._uiSkin:isVisible() then
        self._uiSkin:setVisible(false)
    end
    if self._uiSharePanel ~= nil then
        self._uiSharePanel:hidePanel()
    end
end

function UIWatchPlayerInfo:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIWatchPlayerInfo:onShare(sender)
    if self._uiSharePanel == nil then
        self._uiSharePanel = UISharePanel.new(sender, self._panel)
    end
    local tileInfo = self._tileInfo
    local data = {}
    data.type = ChatShareType.RESOURCE_TYPE
    data.postinfo = {x = tileInfo.buildingInfo.x, y = tileInfo.buildingInfo.y}
    self._uiSharePanel:showPanel(sender, data)
end