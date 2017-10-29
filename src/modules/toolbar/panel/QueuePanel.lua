
QueuePanel = class("QueuePanel", BasicPanel)
QueuePanel.NAME = "QueuePanel"
QueuePanel.TAB_COUNT = 3
QueuePanel.YELLOW_PATH01 = "images/toolbar/btn_yellow_off_f.png"
QueuePanel.YELLOW_PATH02 = "images/toolbar/btn_yellow_on_f.png"
QueuePanel.YELLOW_PATHZHU01 = "images/toolbar/btn_yellow_off_z.png"
QueuePanel.YELLOW_PATHZHU02 = "images/toolbar/btn_yellow_on_z.png"
QueuePanel.GREEN_PATH01 = "images/toolbar/btn_green_off.png"
QueuePanel.GREEN_PATH02 = "images/toolbar/btn_green_on.png"
QueuePanel.GREEN_DAIMING01= "images/toolbar/btn_g_off_d"
QueuePanel.GREEN_DAIMING02= "images/toolbar/btn_g_on_d"
QueuePanel.HELP_MAX_COUNT = 5

-- 列表类型
QueuePanel.LIST_TYPE_XING_JUN = 1
QueuePanel.LIST_TYPE_LAI_XI = 2
QueuePanel.LIST_TYPE_XIE_FANG = 3

function QueuePanel:ctor(view, panelName)
    QueuePanel.super.ctor(self, view, panelName)
end

function QueuePanel:finalize()
    QueuePanel.super.finalize(self)
end

function QueuePanel:initPanel()
	QueuePanel.super.initPanel(self)
    local queueBtn=self:getChildByName("bgPanel/mainPanel")
    queueBtn:setScale(0.1)
    self._tabCount = QueuePanel.TAB_COUNT
    self._changeIndex = 1 -- ³õÊ¼»¯½çÃæ
    self._bgPanel=self:getChildByName("bgPanel")
    self._mainPanel = self:getChildByName("bgPanel/mainPanel")
    self:fixMainPanelPos()
    -- self._queueBtnBg = self:getChildByName("bgPanel/mainPanel/queueBtnBg")
    self._windowScale = NodeUtils:getAdaptiveScale()
    self._queueBtn = self:getChildByName("Panel_212/queueBtnBg/queueBtn")

    self._worldProxy= self:getProxy(GameProxys.World)
    -- local toolp=self._parent:getPanel(ToolbarPanel.NAME)
    -- self._queueBtn:setPosition(toolp:_queueBtn:getPosition())

    -- self._onintMainPosX = self._mainPanel:getPositionX()
    -- self._onintMainPosY = self._mainPanel:getPositionY()
    local retreatConfig = ConfigDataManager:getConfigById(ConfigData.WorldReCallTeamConfig, 1)
    self._retreatMinTime = retreatConfig.minTime
    self._retreatValue   = retreatConfig.percentage/100

    self:addTouchEventListener(self._queueBtn, self.onQueueBtn)

    self:setMask() -- Ìí¼ÓºÚÉ«ÕÚÕÖ
    self._tabBtnList = List.new()   -- 
    self._listViewList = List.new() -- 
    self._botPanelList = List.new() -- 
    
    for i = 1, self._tabCount  do
        local tabBtn = self._mainPanel:getChildByName( string.format("tabBtn%02d",i))
        local listView = self._mainPanel:getChildByName( string.format("queueList%02d",i))
        self._tabBtnList   :pushBack(tabBtn)
        self._listViewList :pushBack(listView)
        tabBtn.index = i
        self:addTouchEventListener(tabBtn, self.onChangeTab)
    end
    -- ³õÊ¼»¯ÏÔÊ¾µÚÒ»¸ö
    self:setTabBtnState(self._tabBtnList:at(self._changeIndex), true)
    for i = 1 , self._listViewList:size() do
        self._listViewList:at(i):setVisible( i == self._changeIndex)
    end
    self._checkTeamPanel = self._mainPanel:getChildByName("checkTeamPanel")
    self._checkTeamPanel:setVisible(self._listViewList:at(2):isVisible())

    self._isInit = true

end

function QueuePanel:registerEvents()
	QueuePanel.super.registerEvents(self)
    local tbtn=self:getChildByName("bgPanel/mainPanel/tabBtn01")
            local t1=tbtn:getChildByName("btnTxt01")
            local t3=tbtn:getChildByName("btnTxt03")
            t1:setColor(cc.c3b(255,255,255))
            t3:setColor(cc.c3b(255,255,255))
end

function QueuePanel:onShowHandler()
--     local tbtn1=self:getChildByName("bgPanel/mainPanel/tabBtn01")
-- self.onChangeTab(tbtn1)
    -- local windowScale = NodeUtils:getAdaptiveScale()
    -- local trueScale = 1 - (windowScale -1)
    -- local winSize = cc.Director:getInstance():getWinSize().width
    local queueBtn_bg=self:getChildByName("bgPanel/queueBtn_bg")
    local act=cc.Sequence:create(cc.ScaleTo:create(0,0.1),cc.ScaleTo:create(0.2,1.5),cc.ScaleTo:create(0.2,0))
    queueBtn_bg:stopAllActions()
    queueBtn_bg:runAction(act)

    local mainPanel=self:getChildByName("bgPanel/mainPanel")
    mainPanel:stopAllActions()
    mainPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0,0),cc.DelayTime:create(0.2),cc.ScaleTo:create(0.2,1)))

    -- local btn1=self:getPanel(ToolbarPanel.NAME)._queueBtn--_queueBtnPos
    -- local pos1=cc.p(btn1:getPositionX(),btn1:getPositionY())
    -- self:getChildByName("Panel_212/queueBtnBg/queueBtn"):setPosition(cc.p(pos1.x+23,pos1.y+12))
    
    -- local initPosX =  self._mainPanel:getPositionX()
    -- local initPosY =  self._mainPanel:getPositionY()
    -- local panelWidth =  self._mainPanel:getContentSize().width *trueScale
    -- local moveToX = initPosX - panelWidth 
    -- moveToX = moveToX - (windowScale- 1)*self._mainPanel:getContentSize().width *trueScale
    -- local moveTo = cc.MoveTo:create(0.2, cc.p(moveToX, initPosY)) 


    -- local function lastCallback()
    --     self._queueBtn:setScaleX(-1)
    --     NodeUtils:removeSwallow()
    -- end
    -- local seqAction = cc.Sequence:create(moveTo, cc.CallFunc:create(lastCallback))
    
    -- self._mainPanel:runAction(seqAction)

    -- ¼ÓÔØµã»÷ÆÁ±Î²ã
    -- NodeUtils:addSwallow()

    self:setTabShow()

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:onTriggerNet80019Req()

end

------
-- ÉèÖÃ¸÷¸ö²ã¼¶µÄÏÔÊ¾
function QueuePanel:setTabShow() 
    -- self:setQueueWorkCount() -- ºìµã
    self:setMarch()
    self:setAttack()
    self:setHelp()
    self:update() -- ¼ÆÊ±
end


------
-- 
function QueuePanel:onChangeTab(btn)
    print(btn.index)
    for i = 1 , self._listViewList:size() do
        if btn.index == i then
            self._listViewList:at(i):setVisible( true)
            self._changeIndex = i
            self:setTabBtnState(self._tabBtnList:at(i), true)
            local tbtn=self:getChildByName("bgPanel/mainPanel/tabBtn0"..i)
            local t1=tbtn:getChildByName("btnTxt01")
            local t3=tbtn:getChildByName("btnTxt03")
            t1:setColor(cc.c3b(255,255,255))
            t3:setColor(cc.c3b(255,255,255))
        else
            self._listViewList:at(i):setVisible(false)
            self:setTabBtnState(self._tabBtnList:at(i), false)
            local tbtn=self:getChildByName("bgPanel/mainPanel/tabBtn0"..i)
            local t1=tbtn:getChildByName("btnTxt01")
            local t3=tbtn:getChildByName("btnTxt03")
            t1:setColor(cc.c3b(135,102,69))
            t3:setColor(cc.c3b(135,102,69))
        end
    end

    if btn.index == QueuePanel.LIST_TYPE_XIE_FANG then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        soldierProxy:onTriggerNet80019Req()
    end

    self._checkTeamPanel:setVisible(self._listViewList:at(2):isVisible())
end

------
-- ÉèÖÃ°´Å¥×´Ì¬
function QueuePanel:setTabBtnState(btn, state)
    if state then
        btn:loadTextures("images/toolbar/btn_tab_on.png", "images/toolbar/btn_tab_on.png", "", 1)
        btn:setTouchEnabled(false)
    else
        btn:loadTextures("images/toolbar/btn_tab_off.png", "images/toolbar/btn_tab_on.png", "", 1)
        btn:setTouchEnabled(true)
    end
end

------
-- ÐÐ¾ü
function QueuePanel:setMarch()
    -- data
    self._soldierProxy = self:getProxy(GameProxys.Soldier)
    local marchData = self._soldierProxy:getSelfTaskTeamInfo()
    -- »ñÈ¡µ±Ç°vipºÍ³öÕ½Êý£¬×î´ó´ÎÊýÉÏÏÞ
    self._vipLevel, self._troopCount, self._maxCount = self:getVipAndTroopCount()
    local itemCount  = 0
    if  self._troopCount < self._maxCount then
        -- Êý¾Ý¼Ó1
        itemCount = self._troopCount +1
    else 
        -- Êý¾Ý²»¼Ó1
        itemCount = self._troopCount  
    end 

    self._trueMarchCount = #marchData


    -- ¼ÓÔØ¿Õ°×Êý¾Ý
    for i = self._trueMarchCount + 1 , itemCount do
        marchData[i] = {}
    end
    -- ¼ÆÊ±ÓÃµÄ±í
    self._marchItemMap = {}
    self._listViewList:at(1):jumpToTop()
    self:renderListView(self._listViewList:at(1), marchData, self, self.renderMarchList)

    -- ÉèÖÃtabÏÔÊ¾
    local btnTxt = self._tabBtnList:at(1):getChildByName("btnTxt")
    
    self:setTabBtnTxt(1, self._trueMarchCount, self._troopCount)
end

------

-- 行军路线
function QueuePanel:renderMarchList(item, data, index)
    local index = index + 1 
    
    local itemPanel = item:getChildByName("itemPanel")
    local tipPanel = item:getChildByName("tipPanel")
    local idleTxt  = item:getChildByName("idleTxt")

    itemPanel:setVisible(false)
    tipPanel:setVisible(false)

   
    if  index <= self._trueMarchCount then
    -- ÕæÊµÊý¾Ý²ã
        -- ¼ÓÔØ´ý¼ÆÊ±Êý¾Ý
        self._marchItemMap[data.id] = {item = item, data = data}
        itemPanel:setVisible(true)
        local iconImg = itemPanel:getChildByName("iconImg")
        local nameTxt = itemPanel:getChildByName("nameTxt")
        local levelTxt = itemPanel:getChildByName("levelTxt")
        local posTitleTxt = itemPanel:getChildByName("posTitleTxt")
        local posTxt = itemPanel:getChildByName("posTxt")
        local gotoBtn = itemPanel:getChildByName("gotoBtn")
        local proBar = itemPanel:getChildByName("proBar")
        local proTxt = itemPanel:getChildByName("proTxt")
        local retreatBtn = itemPanel:getChildByName("retreatBtn")
        -- Ãû¡¢¼¶¡¢Î»
        nameTxt:setString(data.name)
        -- 设置颜色
        local loyaltyCount = data.loyaltyCount
        nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))

        if data.targetType == 1 then
            levelTxt:setString("Lv:"..data.level)
        else
            levelTxt:setString("")
        end
        posTxt:setString("("..data.x..","..data.y..")")
        -- ×ø±êÐÞÕý
        self:setTxtPos(nameTxt, levelTxt)
        -- Í¼±ê
        local url 
	    if data.type == 4 then
		    url = "images/team/daily_1.png"
	    elseif data.type == 5 then
		    url = "images/team/daily_5.png"
	    else
		    url = "images/team/daily_"..data.type..".png"
	    end
	    TextureManager:updateImageView(iconImg, url)
        iconImg:setScale(1.3) -- µ÷ÕûÎª86X86
        -- ½ø¶È
        local key = "teamTask"..data.id
        local remainTime = self._soldierProxy:getRemainTime(key)
        if data.type == 1 or data.type == 2 or data.type == 4 then
        -- ½øÈë¡¢·µ»Ø¡¢³ö·¢¡¢×¤·À
        -- 1³ö·¢È¥Á¸Ìï
            proBar:setPercent(100 * (data.totalTime - remainTime) / data.totalTime)
            proTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))
            -- ¼ÓËÙ°´Å¥
            gotoBtn:loadTextures(QueuePanel.GREEN_PATH01, QueuePanel.GREEN_PATH02, "", 1)--挖矿返回
            -- gotoBtn:setTitleText("")
            -- gotoBtn:setTitleFontSize(16)
        elseif data.type == 3 then  
        --ÍÚ¾ò 
            proBar:setPercent(100 * (data.totalTime - remainTime) * data.product / data.load)
            proTxt:setString(StringUtils:formatNumberByK((data.totalTime - remainTime) * data.product).."/"..StringUtils:formatNumberByK(data.load))
            -- ·µ»Ø°´Å¥
            gotoBtn:loadTextures(QueuePanel.YELLOW_PATH01, QueuePanel.YELLOW_PATH02, "", 1)
            -- gotoBtn:setTitleText(self:getTextWord(4036))--返回
            -- gotoBtn:setTitleFontSize(16)
        elseif data.type == 5 then  
        --×¤·ÀÖÐ
            proBar:setPercent(0)
            proTxt:setString("")
            -- ·µ»Ø°´Å¥
            gotoBtn:loadTextures(QueuePanel.YELLOW_PATH01, QueuePanel.YELLOW_PATH02, "", 1)
            -- gotoBtn:setTitleText(self:getTextWord(4036))
            -- gotoBtn:setTitleFontSize(16)
        elseif data.type == 7 or data.type == 8 then -- -- 盟战,等待开战
            proBar:setPercent(0)
            proTxt:setString(self:getTextWord(471025))
            gotoBtn:loadTextures(QueuePanel.YELLOW_PATH01, QueuePanel.YELLOW_PATH02, "", 1)
        end
        -- ¼ÓËÙ°´Å¥
        -- ´«Êý¾ÝºÍÀàÐÍ
        gotoBtn.data = data
        gotoBtn.type = 1
        itemPanel.isFirstOpen = true
        itemPanel.data = data
        itemPanel.type = 2
        -- ¼ÓËÙ°´Å¥ÏìÓ¦£¬ »¹¿É¼Ó
        self:addInfoBtnTouch(gotoBtn)
        self:addInfoBtnTouch(itemPanel)

        -- 撤军按钮显示
        retreatBtn.data = data
        retreatBtn:setVisible(data.type == 1 or data.type == 4) 
        self:addTouchEventListener(retreatBtn, self.onRetreatBtnHandle)

    elseif index > self._troopCount then
    -- ³äÖµÌáÊ¾²ã
        tipPanel:setVisible(true)
        local rechargeBtn = tipPanel:getChildByName("rechargeBtn") -- ³äÖµ°´Å¥
        rechargeBtn:setTitleColor(ColorUtils:color16ToC3b("#ffffe8cb"))
        local vipTxt = tipPanel:getChildByName("vipTxt")
        local nextOpenLevel = self:getNextOpenLevel(self._vipLevel, self._troopCount)
        vipTxt:setString("VIP"..nextOpenLevel)
        self:addTouchEventListener(rechargeBtn, self.onRecharge)
    end

    


    -- ¿ÕÏÐ¶ÓÁÐÎÄ±¾
    if not itemPanel:isVisible() and not tipPanel:isVisible() then
        idleTxt:setString(self:getTextWord(4035))
    else
        idleTxt:setString("")
    end
end
function QueuePanel:update()
    -- Ë¢ÐÂÐÐ¾ü
    for id, itemData in pairs(self._marchItemMap) do
        local itemPanel = itemData.item:getChildByName("itemPanel")
        local data = itemData.data
        local proBar = itemPanel:getChildByName("proBar")
        local proTxt = itemPanel:getChildByName("proTxt")
        local retreatBtn = itemPanel:getChildByName("retreatBtn")
        local remainTime = self._soldierProxy:getRemainTime("teamTask"..data.id)

        -- ·ÖÀàÅÐ¶Ï
        if data.type == 5 then -- ×¤·ÀÖÐ
            proBar:setPercent(0)
            proTxt:setString(self:getTextWord(7053))
        elseif data.type == 7 or data.type == 8 then -- 盟战/皇城等待开战
--            proBar:setPercent(0)
--            proTxt:setString("")
        elseif data.type == 3 then -- ÍÚ¾ò
            -- µ±Ç°½ø¶È
            local currentProduct = (data.totalTime - remainTime * data.product) 
            if currentProduct >= data.load then
                currentProduct = data.load
            end
            -- data.load ±êÊ¶×Ü½ø¶È
            proBar:setPercent(100 * (currentProduct) / data.load)
            proTxt:setString(StringUtils:formatNumberByK(currentProduct).."/"..StringUtils:formatNumberByK(data.load))
            
        else
            local restTime = data.totalTime - remainTime
            proBar:setPercent(100 * (restTime) / data.totalTime)
            proTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))

            -- 撤军按钮显示remainTime剩余时间
            retreatBtn:setVisible(data.type == 1 or data.type == 4) 
            if data.totalTime <= self._retreatMinTime then
                retreatBtn:setVisible(false)
            elseif restTime >= data.totalTime *self._retreatValue then
                retreatBtn:setVisible(false)
            end
        end
    end
    -- Ë¢ÐÂµÐÏ®
    for index, itemData in pairs(self._attackItemMap) do
        local itemInfo = itemData.data
        local item     = itemData.item
        local proBar   = item:getChildByName("proBar")
        local proTxt   = item:getChildByName("proTxt")
        local keyID = "teamBeAttactionTask"..itemInfo.key
        local remainTime = self._soldierProxy:getRemainTime(keyID)
        proTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))
        proBar:setPercent(( (itemInfo.totalTime  - remainTime)/itemInfo.totalTime)* 100)

    end
    -- Ë¢ÐÂ×¤·À
    for index, itemData in pairs(self._helpItemMap) do
        local itemInfo = itemData.data
        local item     = itemData.item
        local proBar   = item:getChildByName("proBar")
        local proTxt   = item:getChildByName("proTxt")
        local stateTxt  = item:getChildByName("stateTxt")
--        local btn01     = item:getChildByName("btn01")
        local btn02     = item:getChildByName("btn02")
--        local btn03     = item:getChildByName("btn03")

        -- ×´Ì¬Ê±¼ä
        local key = "teamTask"..itemInfo.id
        local lastTime = self._soldierProxy:getRemainTime(key)
        if lastTime <= 0 then
            if itemInfo.state == 1 then
                stateTxt:setString(TextWords:getTextWord(4023))--驻防中
--                btn01:setVisible(true)
--                btn03:setVisible(false)
            else
                stateTxt:setString(TextWords:getTextWord(4030))--待命中
--                btn03:setVisible(true)
--                btn01:setVisible(false)
            end
            proBar:setPercent(0)
            proTxt:setString("") -- ¿Õ
            proBar:setVisible(false)
            proTxt:setVisible(false)
--            -- btn01:setVisible(true)
            btn02:setVisible(true)
        else
            -- Ê±¼äµ¹¼ÆÊ±
            stateTxt:setString(TextWords:getTextWord(4033))--正在路上
            -- percent
            proBar:setPercent( (itemInfo.totalTime - lastTime)/ itemInfo.totalTime *100 )
            proTxt:setString(TimeUtils:getStandardFormatTimeString6(lastTime,true))
            proBar:setVisible(true)
            proTxt:setVisible(true)
--            btn01:setVisible(false)
            btn02:setVisible(false)
--            btn03:setVisible(false)
        end

    end
end         



------
-- 来袭表
function QueuePanel:setAttack()
    local defenseBtn = self._checkTeamPanel:getChildByName("defenseBtn")
    local checkBtn = self._checkTeamPanel:getChildByName("checkBtn")
    self:addTouchEventListener(defenseBtn, self.onDefense)
    self:addTouchEventListener(checkBtn, self.onCheck)
    

    -- Êý¾Ý
    local enemyAttackData = self._soldierProxy:getAttactionData()
    -- 
    self._attackResourceInfo = ConfigDataManager:getConfigData(ConfigData.ResourcePointConfig)
    self._attackItemMap = {}
    self._listViewList:at(2):jumpToTop()
    self:renderListView(self._listViewList:at(2), enemyAttackData, self, self.renderAttackList)


    self:setTabBtnTxt(2, #enemyAttackData)
end

------
-- 驻军协防
function QueuePanel:setHelp()

    local helpData = self._soldierProxy:getBeStationInfo()
    self._helpItemMap = {}
    self._listViewList:at(3):jumpToTop()
    self:renderListView(self._listViewList:at(3), helpData, self, self.renderHelpList)
    
    self:setTabBtnTxt(3, #helpData, QueuePanel.HELP_MAX_COUNT)
end

---------------------------------------------------------------------------------------
--------------------------------------ÐÐ¾üº¯Êý£¬¿ªÊ¼------------------------------------

-- 3 ÊÇ·ñÊÇ×îºóÒ»¸ö
function QueuePanel:getVipAndTroopCount()
    local roleProxy = self:getProxy(GameProxys.Role)
    local vipLevel = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local keyID = vipLevel +1
    local nowVipdData = ConfigDataManager:getConfigById(ConfigData.VipDataConfig, keyID)
    local troopCount = nowVipdData.troopCount
    local maxKeyID = #ConfigDataManager:getConfigData(ConfigData.VipDataConfig)
    local maxCount = ConfigDataManager:getConfigById(ConfigData.VipDataConfig, maxKeyID).troopCount
    return vipLevel,  troopCount , maxCount
end

------
-- Ìø×ªµ½³äÖµ
function QueuePanel:onRecharge()
    ModuleJumpManager:jump( ModuleName.RechargeModule)

end

------
-- »ñÈ¡ÏÂÒ»´Î¸ñ×ÓÔö³¤µÄvipµÈ¼¶
function QueuePanel:getNextOpenLevel(level, troopCount)
    local vipData = ConfigDataManager:getConfigData(ConfigData.VipDataConfig)
    for i = level + 1, #vipData do
        local keyID = i 
        local nextCount = ConfigDataManager:getConfigById(ConfigData.VipDataConfig, keyID).troopCount
        if nextCount > troopCount then
            return keyID - 1
        end
    end
end

------
-- Î»ÖÃÐÞÕý
function QueuePanel:setTxtPos(txt01, txt02, space)
    if space == nil then
        space = 10
    end
    txt02:setPositionX( txt01:getContentSize().width + txt01:getPositionX() + space)
end


------
-- ·µ»ØÆìÖÄ°´Å¥
function QueuePanel:getQueueBtn()
    return self._queueBtn
end

function QueuePanel:setTabBtnTxt(index ,nowPro, allPro )
    local btn = self._tabBtnList:at(index)
    local txt01 = btn:getChildByName("btnTxt01")
    local txt02 = btn:getChildByName("btnTxt02")
    local txt03 = btn:getChildByName("btnTxt03")
    txt02:setString(nowPro)
    if allPro ~= nil then
        txt03:setString("/"..allPro..")") 
    else    
        txt03:setString(")")
    end
    self:setTxtPos(txt01, txt02, 1)
    self:setTxtPos(txt02, txt03, 1)
end


function QueuePanel:setMask()--设置灰色屏幕
    if self._bgPanel.layoutChild == nil then
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(3000, 3000))
        local winSize = self._bgPanel:getContentSize()
        layout:setPosition(cc.p(winSize.width/2, winSize.height/2))
        layout:setBackGroundColor(cc.c3b(0, 0, 0))
        layout:setOpacity(100)
        layout:setAnchorPoint(0.5, 0.5)
        layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        self._bgPanel:addChild(layout, -1)
        layout:setTouchEnabled(true)
        self:addTouchEventListener(layout, self.onQueueBtn)
        self._bgPanel.layoutChild = layout
    end

end


------
-- °´Å¥march°´Å¥¼ÓËÙÏìÓ¦
-- ºÍ·µ»ØµÄÐ­Òé½Ó¿Ú¾ÓÈ»Ò»Ñù@(TeamEvent.ADDSPEED_REQ,{id = sender.data.id})
function QueuePanel:addInfoBtnTouch(infoBtn)
	if infoBtn.isAdd == true or infoBtn.data == nil then
		return
	end
	infoBtn.isAdd = true
	self:addTouchEventListener(infoBtn,self.onInfoClickHandle)
end

function QueuePanel:onInfoClickHandle(sender)
    local key = "teamTask"..sender.data.id
    local remainTime = self._soldierProxy:getRemainTime(key) -- ÔÚbasicProxyÖÐ
	if sender.type == 2 then -- ²é¿´ÐÅÏ¢
        local tmp = {}
        tmp["moduleName"] = ModuleName.CheckTeamModule
        tmp["extraMsg"] = sender.data
        self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, tmp)
    else 
		local time = 0
		local cost = 0
		local function callBack()
			local function callFunc()
			    -- µã»÷È·¶¨
			    self._soldierProxy:onTriggerNet80004Req( {id = sender.data.id} )
			end
			sender.callFunc = callFunc
			sender.money = cost
			self:isShowRechargeUI(sender)
		end
		if sender.data.type == 1  or sender.data.type == 2 or sender.data.type == 4 then
			time = remainTime
			cost = TimeUtils:getTimeCost(time)
		elseif sender.data.type == 3 then
            if (sender.data.totalTime - remainTime * sender.data.product)  >= sender.data.load then
                callBack()
                return
            else
                self:showMessageBox(self:getTextWord(7067),callBack)--采集未满确认要返回?  
                return
            end
        elseif sender.data.type == 5 then -- ×¤¾üÀàÐÍ
            self._soldierProxy:onTriggerNet80004Req( {id = sender.data.id} )
		    return
        elseif sender.data.type == 7 then -- 盟战等待
            self:showMessageBox(self:getTextWord(7096),callBack)
            return
        elseif sender.data.type == 8 then -- 皇城战等待
            self:showMessageBox(self:getTextWord(7097),callBack)
            return
        end

        -- 不可加速的情况
        local data = sender.data
        if data.type == 1 and (data.targetType == 5 or data.targetType == 6) then -- 郡城行军
            self:showSysMessage(self:getTextWord(471032)) -- "郡城行军不能执行加速操作"
            return 
		end

        if data.type == 1 and (data.targetType == 7 or data.targetType == 8) then -- 郡城行军
            self:showSysMessage(self:getTextWord(550010)) -- "皇城行军不能执行加速操作"
            return 
		end

        -- 元宝加速
		self:showMessageBox(self:getTextWord(7055)..cost..self:getTextWord(7068),callBack)
	end
end

------
-- ÊÇ·ñµ¯´°Ôª±¦²»×ã½çÃæ
function QueuePanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money
    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--ÓµÓÐÔª±¦
    if needMoney > haveGold then
        local parent = self:getParent()
        local panel = parent.panel
        if panel == nil then
            local panel = UIRecharge.new(parent, self)
            parent.panel = panel
        else
            panel:show()
        end
    else
        sender.callFunc()
    end
end

---------------------------------------------------------------------------------------
--------------------------------------ÐÐ¾üº¯Êý£¬½áÊø------------------------------------


---------------------------------------------------------------------------------------
---------------------------------------被攻击-----------------------------------
------
-- ÉèÖÃ²¿¶Ó
function QueuePanel:onDefense()
    local data = {}
    data.moduleName = ModuleName.TeamModule
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, data)
end

------
-- ²é¿´²¿¶Ó
function QueuePanel:onCheck()
    local data = {}
    data.moduleName = ModuleName.TeamModule
    data.extraMsg = "workTarget"
    self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, data)
end

------
-- ÉèÖÃattackListViews
function QueuePanel:renderAttackList(item, itemInfo, index)
    local index = index + 1
    -- ´ý¸üÐÂÊý¾Ý
    self._attackItemMap[index] = {item = item , data = itemInfo}

    local iconPanel      = item:getChildByName("iconImg")
    local nameTxt        = item:getChildByName("nameTxt")
    local levelTxt       = item:getChildByName("levelTxt")
    local attackTitleTxt = item:getChildByName("attackTitleTxt")
    local targetTxt      = item:getChildByName("targetTxt")
    local posTxt         = item:getChildByName("posTxt")
    local proBar         = item:getChildByName("proBar")
    local proTxt         = item:getChildByName("proTxt")
     local totalTime = itemInfo.totalTime
    -- Í·Ïñ
    local headInfo = {}
    headInfo.icon = itemInfo.iconId
    headInfo.pendant = itemInfo.iconId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = false
    headInfo.playerId = itemInfo.playerId
    local head = iconPanel.head
    if head == nil then
        head = UIHeadImg.new(iconPanel,headInfo,self)
        head:setScale(0.8)
        iconPanel.head = head
    else
        head:updateData(headInfo)
    end 

    -- Ãû×Ö¡¢µÈ¼¶
    nameTxt:setString(itemInfo.name)
    levelTxt:setString("Lv."..itemInfo.level)
    self:setTxtPos(nameTxt, levelTxt)
    -- µØµã×ø±ê
    if itemInfo.id <= 0 then
        -- ÎÒ·½
        targetTxt:setString(self:getTextWord(7023))
    else
        -- ÆäËû
        targetTxt:setString(self._attackResourceInfo[itemInfo.id].name)
    end
    posTxt:setString("("..itemInfo.x..","..itemInfo.y..")")
    self:setTxtPos(targetTxt, posTxt)

    -- ½ø¶ÈÌõ
    local keyID = "teamBeAttactionTask"..itemInfo.key
    local remainTime = self._soldierProxy:getRemainTime(keyID)
    proTxt:setString(TimeUtils:getStandardFormatTimeString6(remainTime,true))
    -- Ê±¼äÓÐÎÊÌâ
    proBar:setPercent(( (itemInfo.totalTime  - remainTime)/itemInfo.totalTime)* 100)
end

---------------------------------------------------------------------------------------
--------------------------------------µÐÈËÏ®»÷£¬½áÊø------------------------------------

---------------------------------------------------------------------------------------
--------------------------------------驻防------------------------------------
function QueuePanel:renderHelpList(item, itemInfo, index)
    local index = index + 1
    -- ´ý¸üÐÂÊý¾Ý
    self._helpItemMap[index] = {item = item , data = itemInfo}

    local iconPanel = item:getChildByName("iconImg")
    local nameTxt   = item:getChildByName("nameTxt")
    local levelTxt  = item:getChildByName("levelTxt")
    local stateTxt  = item:getChildByName("stateTxt")
    local btn01     = item:getChildByName("btn01")
    local btn02     = item:getChildByName("btn02")
    local btn03     = item:getChildByName("btn03")
    local proBar    = item:getChildByName("proBar")
    local proTxt    = item:getChildByName("proTxt")
    local proBarBg  = item:getChildByName("proBarBg")

    btn01:setVisible(false)
    btn03:setVisible(false)

    -- Í·Ïñ
    local headInfo = {}
    headInfo.icon = itemInfo.icon
    headInfo.pendant = itemInfo.icon
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = "headPendant"
    headInfo.isCreatPendant = true
    headInfo.playerId = itemInfo.playerId
    local head = iconPanel.head
    if head == nil then
        head = UIHeadImg.new( iconPanel, headInfo,self)
        head:setScale(0.8)
        iconPanel.head = head
    else
        head:updateData(headInfo)
    end 
    --head:setHeadSquare(headInfo.icon)


    -- Ãû×Ö¡¢µÈ¼¶
    nameTxt:setString(itemInfo.name)
    levelTxt:setString("Lv."..itemInfo.level)
    self:setTxtPos(nameTxt, levelTxt)
    -- ×´Ì¬Ê±¼ä
    local key = "teamTask"..itemInfo.id
    local lastTime = self._soldierProxy:getRemainTime(key)
    if lastTime <= 0 then
        if itemInfo.state == 1 then
            stateTxt:setString(TextWords:getTextWord(4023))
--            btn01:setVisible(true)
        else
            stateTxt:setString(TextWords:getTextWord(4030))
--            btn03:setVisible(false)
        end
        proBar:setPercent(0)
        proTxt:setString("") -- ¿Õ
        proBar:setVisible(false)
        proTxt:setVisible(false)
        proBarBg:setVisible(false)
        if not proBar:isVisible() then
            stateTxt:setPositionY(20)
        end
        
        btn02:setVisible(true)
    else
        -- Ê±¼äµ¹¼ÆÊ±
        stateTxt:setString(TextWords:getTextWord(4033))
        -- percent
        proBar:setPercent( (itemInfo.totalTime - lastTime)/ itemInfo.totalTime *100 )
        proTxt:setString(TimeUtils:getStandardFormatTimeString6(lastTime,true))
        proBar:setVisible(true)
        proTxt:setVisible(true)
        proBarBg:setVisible(true)
        stateTxt:setPositionY(45)
--        btn01:setVisible(false)
        btn02:setVisible(false)
    end

    -- °´Å¥ÏÔÊ¾
    if itemInfo.state == 1 then
        -- btn01:setTitleText(TextWords:getTextWord(4024))
        -- btn01:loadTextures(QueuePanel.GREEN_DAIMING01,QueuePanel.GREEN_DAIMING02,"",1)
        -- btn01:setTexture(QueuePanel.GREEN_DAIMING01)
--        btn01:setVisible(false)
--        btn03:setVisible(true)
    else
        -- btn01:setTitleText(TextWords:getTextWord(121))
        -- btn01:loadTextures(QueuePanel.YELLOW_PATHZHU01,QueuePanel.YELLOW_PATHZHU02,"",1)
--        btn01:setVisible(true)
--        btn03:setVisible(false)
    end 
    -- °´Å¥ÏìÓ¦
    btn00 = item
    btn00.type = 0 
    btn00.data = itemInfo
--    btn01.type = 1
--    btn01.data = itemInfo
--    btn01.index_num = index 
--    btn03.type = 1
--    btn03.data = itemInfo
--    btn03.index_num = index
    btn02.type = 2
    btn02.data = itemInfo
    btn02.index_num = index 
    self:addTouchEventListener(btn00, self.clickItemButton, nil, self)
--    self:addTouchEventListener(btn01, self.clickItemButton, nil, self)
    self:addTouchEventListener(btn02, self.clickItemButton, nil, self)
--    self:addTouchEventListener(btn03, self.clickItemButton, nil, self)

end

function QueuePanel:clickItemButton(sender)
    self.data = self._soldierProxy:getBeStationInfo()
    if sender.type == 0 then
        local key = "teamTask"..sender.data.id
        local lastTime = self._soldierProxy:getRemainTime(key)
        if lastTime > 0 then
            self:showSysMessage(TextWords:getTextWord(4031))--部队到达后才能查看部队详情
            return
        end
        local tmp = {}
        tmp["moduleName"] = ModuleName.CheckTeamModule
        tmp["extraMsg"] = sender.data
        self:dispatchEvent(ToolbarEvent.SHOW_OTHER_EVENT, tmp)
    elseif sender.type == 1 then
        local playerId = sender.data.id
        local data = {}
        data.id = playerId
        self:dispatchEvent(ToolbarEvent.SET_DEFEND_TEAM, data)
        if sender.data.state == 1 then
            self:showSysMessage(TextWords:getTextWord(4028))--取消军团驻军防守成功
            -- sender:setTitleText(TextWords:getTextWord(4024))--待
            -- sender:loadTextures(QueuePanel.GREEN_DAIMING01,QueuePanel.GREEN_DAIMING02,"",1)
            self:getChildByName("bgPanel/mainPanel/queueList03/itemPanel/btn01"):setVisible(false)
            self:getChildByName("bgPanel/mainPanel/queueList03/itemPanel/btn03"):setVisible(true)--待
            for i=1,#self.data do
                self.data[i].state = 2
            end
            self.data[sender.index_num].state = 2
        else
            self:showSysMessage(TextWords:getTextWord(4029))--设置军团驻军防守成功
            -- sender:loadTextures(QueuePanel.YELLOW_PATHZHU01,QueuePanel.YELLOW_PATHZHU02,"",1)
            -- sender:setTitleText(TextWords:getTextWord(121))--驻
            self:getChildByName("bgPanel/mainPanel/queueList03/itemPanel/btn01"):setVisible(true)--驻
            self:getChildByName("bgPanel/mainPanel/queueList03/itemPanel/btn03"):setVisible(false)
            for i=1,#self.data do
                self.data[i].state = 2
            end
            self.data[sender.index_num].state = 1
        end
        self:setHelp(self.data)
    elseif sender.type == 2 then
        local playerId = sender.data.id
        local data = {}
        data.id = playerId
        self:dispatchEvent(ToolbarEvent.SET_GO_HOME_TEAM, data)
        table.remove(self.data,sender.index_num)
        self:setHelp(self.data)
    end
end

function QueuePanel:fixMainPanelPos()
    local windowScale = NodeUtils:getAdaptiveScale()
    local shouldScale = 2-windowScale-- Ëõ·ÅÓÚÔ­À´ 0.888
    -- local bottomPanel = self:getChildByName("bottomPanel")
    local bgPanel = self:getChildByName("bgPanel")
    bgPanel:setScale(shouldScale)
    -- self._mainPanel:setPositionY( bottomPanel:getContentSize().height)
end

-----
-- ÉèÖÃ¶ÓÁÐºìµã
-- function QueuePanel:setQueueWorkCount()
--     local redDot       = self:getChildByName("bgPanel/mainPanel/queueBtnBg/redDot")
--     local workCountTxt = redDot:getChildByName("workCountTxt")

--     local soldierProxy = self:getProxy(GameProxys.Soldier)
--     local workCount = soldierProxy:getQueueWorkCount()
--     if workCount == 0 then
--         redDot:setVisible(false)
--     else
--         workCountTxt:setString(workCount)
--         redDot:setVisible(true)
--     end
-- end

function QueuePanel:onQueueBtn()
    local tob=self:getPanel("ToolbarPanel")
    -- print(tob)
    -- print(tob.queueclick.."---------------=========================")
    if tob.queueclick==false then
        return
    end
    tob.queueclick=false
    local function canshowqueue()
    tob.queueclick=true
    end
    self._queueBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(canshowqueue)))

--     self._mainPanel:setPosition(self._onintMainPosX, self._onintMainPosY)
    -- self._queueBtn:setScaleX(1)
    local mainPanel=self:getChildByName("bgPanel/mainPanel")
    mainPanel:stopAllActions()
            

    local function lastCallback()
        self:hide()
        self:getPanel(ToolbarPanel.NAME):showFlagQueueBtn()    
    end

   mainPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0),cc.CallFunc:create(lastCallback)))        
end


------
-- 撤军 
-- @param  args [obj] 参数
function QueuePanel:onRetreatBtnHandle(sender)
    local data = {}
    data.id = sender.data.id
    self._soldierProxy:onTriggerNet80017Req(data)
end

-- 隐藏本界面
function QueuePanel:onHideQueuePanel()
    self:onQueueBtn()
end

