--[[
城主战：主界面(城池列表)
]]
LordCityMainPanel = class("LordCityMainPanel", BasicPanel)
LordCityMainPanel.NAME = "LordCityMainPanel"

function LordCityMainPanel:ctor(view, panelName)
    LordCityMainPanel.super.ctor(self, view, panelName)

end

function LordCityMainPanel:finalize()
    LordCityMainPanel.super.finalize(self)
end

function LordCityMainPanel:initPanel()
	LordCityMainPanel.super.initPanel(self)
	
	self.allLen = 0
	self._cityPanelList = {}
    self._myQualify = -1

	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
	self._chatProxy = self:getProxy(GameProxys.Chat)
	self:initConfigData()

    local downPanel = self:getChildByName("downPanel")
    self._barrage = UIChatBarrage.new(self,downPanel)
    self._barrage:setHeight(44)

end

function LordCityMainPanel:registerEvents()
	LordCityMainPanel.super.registerEvents(self)

	self._middlePanel = self:getChildByName("middlePanel")
	self._downPanel = self:getChildByName("downPanel")

	-- 城池列表
	local cityPanel
	for i=1,4 do
		cityPanel = self._middlePanel:getChildByName("cityPanel"..i)
		if cityPanel then
			self._cityPanelList[i] = cityPanel
            self._cityPanelList[i].cityIndex = i
			self:updateRewardBox(cityPanel,0) ----初始化隐藏宝箱
			cityPanel:setVisible(false)
			local timeBg = cityPanel:getChildByName("timeBg")
			timeBg:setVisible(false)
		end
	end

	-- 背景图
	self._bgImg = self:getChildByName("bgImg")
	TextureManager:updateImageViewFile(self._bgImg,"bg/lordCity/bg.jpg")
    local spr = self._bgImg:getVirtualRenderer()
    

    --NodeUtils:nodeBlur(spr)
    --local size = spr:getContentSize()
    --spr:setPosition(size.width * 0.5, size.height * 0.5)
    --self._bgImg.addChild(spr)


	-- 聊天
	self._chatTxt = self:getChildByName("downPanel/chatTxt")
	self._chatDotBg = self:getChildByName("downPanel/chatBtn/dotBg")
	self._chatDotTxt = self:getChildByName("downPanel/chatBtn/dot")
	self:addTouchEventListener(self._downPanel, self.onChatBtnTouch)
	self._chatDotBg:setVisible(false)
	self._chatDotTxt:setVisible(false)

	-- 顶部UI
	self._topInfoPanel = self:getChildByName("topInfoPanel")
	self._helpBtn = self:getChildByName("topInfoPanel/helpBtn")
	self._closeBtn = self:getChildByName("topInfoPanel/closeBtn")
	self:addTouchEventListener(self._helpBtn, self.onHelpBtnTouch)
	self:addTouchEventListener(self._closeBtn, self.onClosePanelHandler)
	self._topInfoPanel:setVisible(true)

	--参战资格UI
	self._powerPanel = self:getChildByName("topInfoPanel/powerPanel")
	self._powerBtn = self:getChildByName("topInfoPanel/powerPanel/powerBtn")
	self._powerTxt = self:getChildByName("topInfoPanel/powerPanel/powerTxt")
	self:addTouchEventListener(self._powerBtn, self.onPowerBtnTouch)  --参战资格按钮
	self._powerPanel:setVisible(false)  --初始化隐藏，拿到协议数据时候才显示

end

-- 360046返回更新我的参战资格显示
function LordCityMainPanel:onQualifyUpdate()
	self:updatePowerPanel()
end

function LordCityMainPanel:onPowerBtnTouch(sender)
	local panel = self:getPanel(LordCityPowerPanel.NAME)
	if panel then
		-- self._lordCityProxy:onTriggerNet360046Req({cityId = self._powerCityId})
		self._lordCityProxy:onTriggerNet360046Req({})
		panel:show()
	end
end

function LordCityMainPanel:onHelpBtnTouch()
	SDKManager:showWebHtmlView("html/help_cityFight.html")
end

function LordCityMainPanel:onClosePanelHandler()
	self:dispatchEvent(LordCityEvent.HIDE_SELF_EVENT, {})
end

function LordCityMainPanel:doLayout()
	local upWidget = self:getChildByName("topInfoPanel")
    NodeUtils:adaptivePanelBg(self._bgImg, 0, self:getChildByName("topAdaptivePanel"))
    --NodeUtils:adaptiveTopPanelAndListView(self._middlePanel, nil, GlobalConfig.downHeight, upWidget)
end

function LordCityMainPanel:onAfterActionHandler()
	self:onShowHandler()
end

function LordCityMainPanel:onShowHandler()
	if self:isModuleRunAction() == true then
		return
	end

	self._lordCityProxy:onTriggerNet360046Req({})

	self:updateMiddlePanel()
	self:updatePowerPanel()
	self:resumeAllCCB()

	self:updateChatInfos( {self._chatProxy:getLastChatInfo()} )  --聊天
end

-------------------------------------------------------------------------------
-- 数据更新
-------------------------------------------------------------------------------
function LordCityMainPanel:onCityInfoMapUpdate()
	self:onShowHandler()
end
function LordCityMainPanel:onCityInfoUpdate()
	self:onShowHandler()
end
function LordCityMainPanel:onStateChangeUpdate(data)
	-- print("......... 城池占领状态变更显示")
end
function LordCityMainPanel:onRewardUpdate(data)
	-- print("......... 城池宝箱领取状态变更显示")
	self:updateRewardState(data)
end

--城池列表显示 休战中/争夺准备时间/争夺剩余时间
function LordCityMainPanel:updateCityRemainTime()
	local cityInfoMap = self._lordCityProxy:getCityInfoMap()
	local cityHostMap = self._lordCityProxy:getCityHostMap()

	for k,info in pairs(cityInfoMap) do
		local cityPanel = self._cityPanelList[info.cityId]
		if cityPanel then
			local remainTime = 0
			local state = 0
			local cityHost = cityHostMap[info.cityId]

			-- if cityHost then
			-- 	logger:info("列表 cityId=%d, cityState=%d, cityState=%d rewardState=%d", info.cityId, info.cityState, cityHost.cityState, info.rewardState)
			-- end
			-- logger:info("城池列表下次开启时间 startTime=%d cityId=%d",info.startTime,info.cityId)

			-- //主城状态 0：关闭，2：准备，3：开启
			if cityHost == nil or info.cityState == 0 or cityHost.cityState == 0 then  --休战中
				state = 0  --休战中
			else
				state = 2  --准备中
				remainTime = self._lordCityProxy:getBattleReadyRemainTime(info.cityId)  --剩余准备时间
				if remainTime <= 0 then
					state = 3  --争夺中
					remainTime = self._lordCityProxy:getBattleRemainTime(info.cityId)  --剩余争夺时间
					-- if remainTime <= 0 and info.cityState ~= 0 then  --争夺时间已为0，info.cityState还没刷新
						-- state = 0
						-- logger:info("= --争夺时间已为0，info.cityState还没刷新 %d %d",remainTime,info.cityState)
						-- self._lordCityProxy:onTriggerNet360010Req()
					-- end
				end
				remainTime = TimeUtils:getStandardFormatTimeString(remainTime)
			end
			
			local timeBg = cityPanel:getChildByName("timeBg")
			local stateTxt = timeBg:getChildByName("stateTxt")
			local stateTime = timeBg:getChildByName("remainTime")
			timeBg:setVisible(true)
			stateTime:setVisible(state ~= 0)
			stateTime:setString(remainTime)
			--stateTime:setPositionX(stateTxt:getPositionX() + stateTxt:getContentSize().width)

			if state ~= 0 then
				self._powerCityId = info.cityId
			end

			self:setStateTxt(stateTxt,state, cityPanel)
			self:updateCityCCB(cityPanel,state)
		end
	end
	
end

-------------------------------------------------------------------------------
-- 争夺规则弹窗
function LordCityMainPanel:showRuleTips()
	local parent = self:getParent()
    local uiTip = UITip.new(parent)

    local lines = {}
    local text = nil
    local tmp = nil
    local fontSize,color = nil,nil
    for i=1,23 do
    	text = self:getTextWord(372000-1+i)
    	tmp = string.sub(text,1,1)
    	-- print("..... 截取字符串",tmp)

    	if tmp == "\n" then
 			-- print("...标题！！！",text)
    		fontSize = ColorUtils.tipSize18
    		color = ColorUtils.wordColorDark1602
    	else
    		fontSize = ColorUtils.tipSize16
    		color = ColorUtils.wordColorDark1601
    	end

    	local line = {{content = text, foneSize = fontSize, color = color}}
	    table.insert(lines, line)
    end
    uiTip:setAllTipLine(lines)

end
-------------------------------------------------------------------------------
-- 主界面城池列表
-------------------------------------------------------------------------------
-- 城池列表信息
function LordCityMainPanel:updateMiddlePanel()
	local data = self._lordCityProxy:getCityInfoMap()
    local i = 1
	for _,info in pairs(data) do
		local cityPanel = self._cityPanelList[info.cityId]
		if cityPanel then
			self:updateCityPanel(cityPanel,info)
			self:updateCityCCB(cityPanel,info.cityState)
		end
        i = i + 1
	end
	self:createCCBSmokeM(self._middlePanel, true)
end

function LordCityMainPanel:updateCityCCB(cityPanel,cityState)
	if cityPanel== nil or cityState == nil then
		return
	end
	self:createCCBKnifeM(cityPanel, cityState ~= 0)
	self:createCCBKuangM(cityPanel, cityState ~= 0)
end

-- 渲染单个 城池信息
function LordCityMainPanel:updateCityPanel(cityPanel,data)
	if cityPanel == nil or data == nil then
		return
	end
	local config = self._cityConfig[data.cityId]
	if config == nil then
		logger:error(".........城池配表信息 config is nil (ID=%d)......",data.cityId)
		return
	end

	cityPanel:setVisible(true)
	cityPanel:setBackGroundColorOpacity(0)

	local cityImg = cityPanel:getChildByName("cityImg")
	local detailTxt = cityPanel:getChildByName("detailTxt")
	local cityName = cityPanel:getChildByName("cityName")
	local cityNum = cityPanel:getChildByName("cityNum")
	local rewardBtn = cityPanel:getChildByName("rewardBtn")  --宝箱奖励
    rewardBtn:setVisible(false)
	local stateTxt = cityPanel:getChildByName("stateTxt")  --显示未开启的提示

	cityImg:setVisible(true)

	local urlCity = string.format("bg/map/iconCity%d.png",config.icon)
	local urlName = string.format("images/lordCity/Txt_name%d.png",data.cityId)
	local urlNum = string.format("images/lordCity/Txt_num%d.png",data.cityId)
	TextureManager:updateImageViewFile(cityImg, urlCity)
	TextureManager:updateImageView(cityName, urlName)
	TextureManager:updateImageView(cityNum, urlNum)
    --if config.icon == 2 or config.icon == 4 then
    --    cityImg:setScaleX(-1)
    --end
    
	--local scale = self._lordCityProxy:getCityScaleById(data.cityId)
	cityImg:setScale(config.iconScale / 100)

	-- 占领状态
	local nameStr,naemColor
	if data.legionName ~= "" then  --已占领
		nameStr = data.legionName
		naemColor = ColorUtils.commonColor.Red
	else  --未占领
		nameStr = self:getTextWord(370000)
		naemColor = ColorUtils.commonColor.Green
	end

	-- 开始时间
	local txtNo = self:getTextWord(370000 + config.timeID)
	local hour = string.sub(config.prepareTime,1,2)
	local min = string.sub(config.prepareTime,3,4)
	local timeStr = hour .. ":" .. min
	txtNo = string.format(txtNo,timeStr)

	timeStr = {
		{{self:getTextWord(370079), 18, ColorUtils.commonColor.FuBiaoTi},{nameStr, 18, naemColor},},
		{{self:getTextWord(370078), 18, ColorUtils.commonColor.FuBiaoTi},{txtNo, 18, ColorUtils.commonColor.Green},},
	}

	detailTxt:setString("")
    local richLabel = detailTxt.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        detailTxt:addChild(richLabel)
        detailTxt.richLabel = richLabel
    end
    richLabel:setString(timeStr)



	cityPanel.data = data
	cityPanel.config = config

	if cityPanel.isAddEvent == nil then
		cityPanel.isAddEvent = true
		self:addTouchEventListener(cityPanel, self.onCityBtnTouch)
	end

	rewardBtn.cityId = data.cityId
	cityPanel.rewardBtn = rewardBtn
	if rewardBtn.isAddEvent == nil then
		rewardBtn.isAddEvent = true 
		self:addTouchEventListener(rewardBtn, self.onRewardBtnTouch)
	end
	
	-- 渲染宝箱
	self:updateRewardBox(cityPanel,data.rewardState)

	--开启状态的提示文字
	self:setStateTxt(stateTxt, data.cityState, cityPanel)
end

-- 主界面城池 匕首攻击特效
function LordCityMainPanel:createCCBKnifeM(panel, isShow)
	if panel == nil then
		return
	end

	local cityImg = panel:getChildByName("cityImg")
	if cityImg == nil then
		return
	end

	local knifeM = cityImg.knifeM
    if knifeM == nil then
        knifeM = self:createUICCBLayer("rgb-zcz-pishou", cityImg)
        local size = cityImg:getContentSize()
        knifeM:setPosition(size.width/2 + 20,size.height/2 + 30)
        cityImg.knifeM = knifeM
        self:addCCBToMap(knifeM)
    end
    knifeM:setVisible(isShow)
end

-- 主界面城池 列表项边框特效
function LordCityMainPanel:createCCBKuangM(panel, isShow)
	if panel == nil then
		return
	end
	
	local bgImg = panel:getChildByName("bgImg")
	local effectPanel = bgImg:getChildByName("effectPanel")
	if bgImg == nil or effectPanel == nil then
		return
	end
    
	local kuangM = bgImg.kuangM
    if kuangM == nil then
        kuangM = self:createUICCBLayer("rpg-zcz-hxk", effectPanel)
        local size = bgImg:getContentSize()
        kuangM:setPosition(size.width/2,size.height/2 - 4)
        bgImg.kuangM = kuangM
        self:addCCBToMap(kuangM)
    end
    if panel.cityIndex == 2 or panel.cityIndex == 4 then
        effectPanel:setScaleX(-1)
    end
    kuangM:setVisible(isShow)
    
end

-- 主界面城池 烟雾特效
function LordCityMainPanel:createCCBSmokeM(panel, isShow)
	if panel == nil then
		return
	end

	local smokeM = panel.smokeM
    if smokeM == nil then
        smokeM = self:createUICCBLayer("rpg-zcz-yw", panel)
        smokeM:setPosition(320,320)
        panel.smokeM = smokeM
        self:addCCBToMap(smokeM)
    end
    smokeM:setVisible(isShow)
end

--恢复全部特效
function LordCityMainPanel:resumeAllCCB()
	local ccbiMap = self._ccbiMap
	if ccbiMap == nil then
		logger:info("= -- 根据显示类型，无法恢复特效~~~！！！ %d=",key)
		return
	end
    for k, v in pairs(ccbiMap) do
        if v:isFinalize() == true then 
            ccbiMap[k] = nil
        else
            -- logger:info("= -- 根据显示类型，恢复特效 =")
            v:resume()
        end
    end
end

function LordCityMainPanel:addCCBToMap(ccb)
	if self._ccbiMap == nil then
		self._ccbiMap = {}
	end
	table.insert(self._ccbiMap,ccb)
end
-------------------------------------------------------------------------------

-- 更新城池宝箱的领取状态显示
function LordCityMainPanel:updateRewardState(data)
	local cityId = data.cityId
	local rewardState = data.rewardState

	local cityPanel = self._cityPanelList[cityId]
	if cityPanel then
		self:updateRewardBox(cityPanel,2)
		-- local rewardBtn = panel.rewardBtn
		-- local normalUrl = "images/lordCity/boxOpen.png"
		-- TextureManager:updateButtonNormal(sender, normalUrl)
	end
end

function LordCityMainPanel:updateRewardBox(panel,state)
	local rewardBtn = panel.rewardBtn
	if rewardBtn then
		if state ~= 0 then
			local normalUrl = "images/lordCity/boxClose.png"
			if state == 2 then
				normalUrl = "images/lordCity/boxOpened.png"
			end
			TextureManager:updateButtonNormal(rewardBtn, normalUrl)
			rewardBtn:setVisible(true)

            rewardBtn:setVisible(false)
		else
			rewardBtn:setVisible(false)
		end
	end

end

function LordCityMainPanel:onStateUpdate(data)
	--开启状态的提示文字的更新
	local cityId,cityState = data.cityId,data.cityState
	local cityPanel = self._cityPanelList[cityId]
	if cityPanel then
		local timeBg = cityPanel:getChildByName("timeBg")
		local stateTxt = timeBg:getChildByName("stateTxt")
		if stateTxt then
			self:setStateTxt(stateTxt, cityState, cityPanel)
		end
	end
end

function LordCityMainPanel:setStateTxt(stateTxt, cityState, cityPanel)
	if stateTxt == nil or cityState == nil then
		return
	end
	-- print("...--开启状态",cityState)
	
	--开启状态的提示文字
	local stateStr = ""
	local stateColor
	if cityState == 2 then  --准备阶段
		stateStr = self:getTextWord(370080)
		--stateColor = "#10e6ff"
        stateColor = cc.c3b(16,230,255)
	elseif cityState == 3 then  --争夺阶段
		stateStr = self:getTextWord(370081)
		--stateColor = "#ff8b3d"
        stateColor = cc.c3b(255,139,61)
	else  --未开启
		stateStr = ""--self:getTextWord(370082)
		--stateColor = "#b6b6b6"
        stateColor = cc.c3b(182,182,182)
	end
	stateTxt:setString(stateStr)
	stateTxt:setColor(stateColor)
    
    -- 更新城市状态图标
	if cityPanel == nil or cityState == nil then
		return
	end
    local imgStatusMark = cityPanel:getChildByName("imgStatusMark")
    imgStatusMark.cityState = cityState
	if cityState == 2 or cityState == 3 then  --
        if self._myQualify == 0 then--or self._myQualify == 1 
            TextureManager:updateImageView(imgStatusMark, "images/lordCity/iconWatchFight.png")
        else
            TextureManager:updateImageView(imgStatusMark, "images/lordCity/iconJoinFight.png")
        end
	else  --未开启
        TextureManager:updateImageView(imgStatusMark, "images/lordCity/iconTruce.png")
	end
    imgStatusMark:setVisible(true)
end

function LordCityMainPanel:initConfigData()
	self._cityConfig = ConfigDataManager:getConfigDataBySortId(ConfigData.CityBattleConfig)
end

function LordCityMainPanel:updatePowerPanel()
	self._powerPanel:setVisible(true)

	local fontSize = 20
	local qStr = ""
	local qColor = ""
	local myQualify = self._lordCityProxy:getMyQualify()
    self._myQualify = myQualify
	if myQualify == 0 then --不可参战
		qStr = self:getTextWord(370092)
		qColor = ColorUtils.commonColor.Red
	elseif myQualify == 1 then  --可参战
		qStr = self:getTextWord(370093)
		qColor = ColorUtils.commonColor.Green
	end
	local infoStr = {{{self:getTextWord(370091),fontSize, ColorUtils.commonColor.BiaoTi},{qStr,fontSize,qColor}}}

	local richLabel = self._powerTxt.richLabel
	if richLabel == nil then
	    richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
	    self._powerTxt:addChild(richLabel)
	    self._powerTxt.richLabel = richLabel
	end
	self._powerTxt:setString("")
	richLabel:setString(infoStr)

	-- 居中显示
	local size = richLabel:getContentSize()
	local x = - size.width/2
	richLabel:setPositionX(x)
    
    for i = 1, 4 do
        local cityPanel = self._middlePanel:getChildByName("cityPanel" .. i)
        local imgStatusMark = cityPanel:getChildByName("imgStatusMark")
        --imgStatusMark:setVisible(true)
        if imgStatusMark.cityState == 2 or imgStatusMark.cityState == 3 then
            if myQualify == 0 then --不可参战
                TextureManager:updateImageView(imgStatusMark, "images/lordCity/iconWatchFight.png")
            end
        end
    end

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 点击城池
function LordCityMainPanel:onCityBtnTouch(sender)
	local cityId = sender.data.cityId
	if cityId == nil then
		logger:error("-- 点击城池 cityId = nil ")
		return
	end

	self._lordCityProxy:setSelectCityId(cityId)
	
	local data = {cityId = cityId}
	-- 主界面 则弹城池详细信息
	self._lordCityProxy:onTriggerNet360011Req(data)
	self._lordCityProxy:onTriggerNet360042Req(data)
	local panel = self:getPanel(LordCityInfoPanel.NAME)
	panel:show()
end

-- 点击宝箱领奖
function LordCityMainPanel:onRewardBtnTouch(sender)
	local cityInfo = self._lordCityProxy:getCityInfoById(sender.cityId)
	if cityInfo.rewardState == 2 then
		self:showSysMessage(self:getTextWord(370084))  --当天已领取过
		return
	end
	local data = {cityId = sender.cityId}
	self._lordCityProxy:onTriggerNet360031Req(data)
end

-------------------------------------------------------------------------------
-- 聊天信息刷新
function LordCityMainPanel:updateChatInfos(chats)    
    if self.allLen == 0 then
        self.allLen = table.size(chats)
    else
        self.allLen = self.allLen + table.size(chats)
    end
    if chats[table.size(chats)] then
        self:updateChatLineInfo(chats[table.size(chats)])
    end
end

function LordCityMainPanel:updateChatLineInfo(chat)
    local chatProxy = self:getProxy(GameProxys.Chat)
    self:renderChatNum(chatProxy:getAllReadChatNum())
    self.isCanDisappear = 0
    if chat.playerId ~= self._ID or chat.extendValue == 1 then
        self.chatInfoNumber = self.allLen
        if self.chatInfoNumber >= 5 then
            self.chatInfoNumber = 5
        end
    end
    --------jjjjj

    local context = chat.context
    if chat.contextType == 2 then --语音不显示内容
        context = ""
    end
 
    self._chatTxt:setVisible(false)
    self._chatTxt:setString("")

    local nameSize = self._chatTxt:getContentSize()
    local nameX = self._chatTxt:getPositionX()
    if StringUtils:isFixed64Zero(chat.playerId) == false and StringUtils:isGmNotice(chat.playerId) == false then
        local chatText = ""
        local redBag = nil
        if chat.extendValue ~= 1 and rawget(chat, "isShare") ~= true then
            --chatText = chat.name..":"..chat.context
            chatText = chat.context
        else
            redBag = RichTextMgr:getInstance():getNoticeParams(chat.context)
            if chat.extendValue == 1 then
                redBag[1].txt = redBag[1].txt..":"
            end
            --不能去掉，红包富文本带data字段会导致不能点击
            for k,v in pairs(redBag) do
                if rawget(v, "data") ~= nil then
                    redBag[k].data = nil
                end
                -- if rawget(v, "isUnderLine") ~= nil then
                --     redBag[k].isUnderLine = nil
                -- end
            end
        end

        chatText = StringUtils:formatShortContent(chatText, 20)
        local chatParams = ComponentUtils:getChatItem(chatText, 0.6)
        if chat.extendValue == 1 or rawget(chat, "isShare") then
            chatParams = redBag
        elseif chat.extendValue == 3 then 
            local p = {}
            p.txt = chat.name .. ":" ..TextWords:getTextWord(391009)
            table.insert(chatParams, 1, p)
        else
            local p = {}
            p.txt = chat.name .. ":"
            table.insert(chatParams, 1, p)
        end
        
        
        if self._chatItem == nil then
            self._chatItem = RichTextMgr:getInstance():getRich(chatParams, 320, nil, nil, nil, 2)
            self._chatTxt:getParent():addChild(self._chatItem)
        else
            self._chatItem:setData(chatParams)
        end
        self._chatItem:setVisible(true)
        self._chatItem:setAnchorPoint(0, 0.5)
        self._chatItem:setPosition(self._chatTxt:getPosition())
    else
        if self._chatItem ~= nil then
            self._chatItem:setVisible(false)
        end
        self._chatTxt:setVisible(true)
        local text = RichTextMgr:getInstance():getNoticeParams(chat.context, true)
        local labelText = chat.name..":"..text
        local chatText = StringUtils:formatShortContent(labelText, 20)
        self._chatTxt:setColor(ColorUtils.wordGreenColor)
        self._chatTxt:setString(chatText)
    end
end

--更新聊天的小红点
function LordCityMainPanel:renderChatNum(param)
    self._chatDotTxt:setVisible(false)  --聊天面板实时刷新，这里就不显示小红点了    
    self._chatDotBg:setVisible(false)  --聊天面板实时刷新，这里就不显示小红点了    
end

-- 点击聊天
function LordCityMainPanel:onChatBtnTouch(sender)
    self.chatInfoNumber = 0
    self._chatDotTxt:setString("")

    local data = {}
    data.moduleName = ModuleName.ChatModule
    data.srcModule = ModuleName.LordCityModule   --关闭目标模块，重新打开当前模块
    data.srcExtraMsg = {panelName = "LordCityMainPanel"}

    self:dispatchEvent(LordCityEvent.SHOW_OTHER_EVENT, data)
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function LordCityMainPanel:update()
	self:updateCityRemainTime()
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


function LordCityMainPanel:onUpdateBarrage(data)
      for k,v in pairs(data) do
        if v.context ~= 2 then
            if v.name ~= "系统公告" then
            TimerManager:addOnce(1000,self._barrage:updateDataChat(k,v),self) 
            end
        end 
    end  
end