-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2016-12-23
--  * @Description: 武学讲堂
--  */
MartialMainPanel = class("MartialMainPanel", BasicPanel)
MartialMainPanel.NAME = "MartialMainPanel"

function MartialMainPanel:ctor(view, panelName)
    MartialMainPanel.super.ctor(self, view, panelName)
    
end

function MartialMainPanel:finalize()
    MartialMainPanel.super.finalize(self)
end

function MartialMainPanel:initPanel()
	MartialMainPanel.super.initPanel(self)
	for i=1,3 do
		self["typeBtn" .. i] = self:getChildByName("topPanel/typeBtn" .. i)
		self["typeBtn" .. i].tag= i
		self:addTouchEventListener(self["typeBtn" .. i],self.chooseTypeHandler)
	end
	self.selectedTag = 1
	for i=1,4 do
		self["rewardImg" .. i] = self:getChildByName("topPanel/rewardShowPanel/img" .. i)
	end
	self.rewardShowPanel = self:getChildByName("topPanel/rewardShowPanel")
	self.proxy = self:getProxy(GameProxys.Activity)
	local descLab = self:getChildByName("topPanel/descLab")
	descLab:setString(string.format("%s\n%s", self:getTextWord(260002),self:getTextWord(392005)))
    --descLab:setFontSize(18)
    descLab:setColor(cc.c3b(244,244,244))
    --descLab:setPositionX(53)
	--特效播放标记
	self.isLearning = false
	
end
function MartialMainPanel:onShowHandler()
	self:updateMartialView()
end
function MartialMainPanel:updateMartialView()
		--获得获得数据  
	self.myData = self.proxy:getCurActivityData()

	local martialGroupJson = ConfigDataManager:getConfigById(ConfigData.MartialManageConfig, self.myData.effectId).martialGroup
	self.moniData = StringUtils:jsonDecode(martialGroupJson)
	self._type = {}

	for i=1,3 do
        local config = ConfigDataManager:getConfigById(ConfigData.MartialTeachConfig, self.moniData[i])
        table.insert(self._type, config.type)
		-- self["typeBtn" .. i]:setTitleText(ConfigDataManager:getConfigById(ConfigData.MartialTeachConfig, self.moniData[i]).name)
		local url = string.format("images/martialTeach/%d.png", config.type)
        if self.selectedTag == i then
            url = string.format("images/martialTeach/%d_selected.png", config.type)
        end 
		local img = self["typeBtn" .. i]:getChildByName("img")
		TextureManager:updateImageView(img, url)
	end

	local timeDescLab = self:getChildByName("topPanel/timeDescLab")
	-- local startTime = self:timestampToString(self.myData.startTime)
	-- local endTime = self:timestampToString(self.myData.endTime)
	-- if startTime == 0 or endTime == 0 then
	-- 	timeDescLab:setString("")
	-- else
	-- 	timeDescLab:setString(string.format("%s%s%s%s", self:getTextWord(392006),startTime,self:getTextWord(392008),endTime))
	-- end
	timeDescLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
    --timeDescLab:setFontSize(18)
    timeDescLab:setColor(cc.c3b(43,165,50))	
    --timeDescLab:setPositionX(51)

	self:updateTypeReward(self.selectedTag or 1 ,false)

	self:updateRankData()

	local myScoreLab = self:getChildByName("topPanel/myScoreLab")
	local martialInfo = self.proxy:getMartialInfoById(self.myData.activityId)
	myScoreLab:setString(martialInfo.learnTimes)

end
function MartialMainPanel:updateTypeReward( tag ,isEffect)
	local topPanel = self:getChildByName("topPanel")
	--变灰
	for i=1,3 do
		local url = string.format("images/martialTeach/%d.png", self._type[i])
		if i == tag then
			--self["typeBtn" .. i]:setColor(cc.c3b(255,255,255))
            
		    TextureManager:updateButtonNormal(self["typeBtn" .. i], "images/martialTeach/on.png")
            url = string.format("images/martialTeach/%d_selected.png", self._type[i])
		else
		    TextureManager:updateButtonNormal(self["typeBtn" .. i], "images/martialTeach/off.png")
			--self["typeBtn" .. i]:setColor(cc.c3b(155,155,155))
		end
		local img = self["typeBtn" .. i]:getChildByName("img")
		TextureManager:updateImageView(img, url)
	end
	--换中间类型图
	local learnTipsLab = self:getChildByName("topPanel/rewardShowPanel/learnTipsLab")
	local colorAry = {cc.c3b(104, 253, 2) , cc.c3b(4, 157, 242) , cc.c3b(195, 5, 220) , cc.c3b(221, 76, 7)}
	learnTipsLab:setColor(colorAry[self._type[tag]])
	--换中间讲师的图
	local teacherImgUrl = string.format("images/martialTeach/%d%d%d.png", self._type[tag],self._type[tag],self._type[tag])
	local teacherImg = self:getChildByName("topPanel/teacherImg")
	TextureManager:updateImageView(teacherImg, teacherImgUrl)

	--
	local selectedTag = tag or self.selectedTag or 1
	for i=1,4 do
		self["rewardImg" .. i]:setVisible(false)
	end
	local config = ConfigDataManager:getConfigById(ConfigData.MartialTeachConfig, self.moniData[selectedTag])
	local rewardIDjson =  config.rewardID
    local rewardAry = StringUtils:jsonDecode(rewardIDjson)
    local roleProxy = self:getProxy(GameProxys.Role)
    if isEffect == true then
    	--切换依次出现icon
	    local icon23Callfunc =  cc.CallFunc:create(function ()
	    	if rewardAry[2] then
			    local iconData = {}
			    iconData.typeid = rewardAry[2][2]
			    iconData.num = rewardAry[2][3]
			    iconData.power = rewardAry[2][1]
			    if self.rewardImg2.uiIcon == nil then
				    self.rewardImg2.uiIcon = UIIcon.new(self.rewardImg2, iconData, true, self, nil, true)
			    else
				    self.rewardImg2.uiIcon:updateData(iconData)
			    end
		        self.rewardImg2:setVisible(true)
                self.rewardImg2.uiIcon:setNameFontSize(18)
                self.rewardImg2.uiIcon:setNameTxtBg()
				self.rewardImg2:setOpacity(0)
		    	local fadeIn = cc.FadeIn:create(0.5)
		        self.rewardImg2:runAction(fadeIn)
		    end
	    	if rewardAry[3] then
			    local iconData = {}
			    iconData.typeid = rewardAry[3][2]
			    iconData.num = rewardAry[3][3]
			    iconData.power = rewardAry[3][1]
			    if self.rewardImg3.uiIcon == nil then
				    self.rewardImg3.uiIcon = UIIcon.new(self.rewardImg3, iconData, true, self, nil, true)
			    else
				    self.rewardImg3.uiIcon:updateData(iconData)
			    end
		        self.rewardImg3:setVisible(true)
                self.rewardImg3.uiIcon:setNameFontSize(18)
                self.rewardImg3.uiIcon:setNameTxtBg()
				self.rewardImg3:setOpacity(0)
		    	local fadeIn = cc.FadeIn:create(0.5)
		        self.rewardImg3:runAction(fadeIn)
		    end
	    end)
		local icon14Callfunc =  cc.CallFunc:create(function ()

	    	if rewardAry[1] then
			    local iconData = {}
			    iconData.typeid = rewardAry[1][2]
			    iconData.num = rewardAry[1][3]
			    iconData.power = rewardAry[1][1]
			    if self.rewardImg1.uiIcon == nil then
				    self.rewardImg1.uiIcon = UIIcon.new(self.rewardImg1, iconData, true, self, nil, true)
			    else
				    self.rewardImg1.uiIcon:updateData(iconData)
			    end
		        self.rewardImg1:setVisible(true)
                self.rewardImg1.uiIcon:setNameFontSize(18)
                self.rewardImg1.uiIcon:setNameTxtBg()
		        self.rewardImg1:setOpacity(0)
		    	local fadeIn = cc.FadeIn:create(0.5)
		        self.rewardImg1:runAction(fadeIn)
		    end
	    	if rewardAry[4] then
			    local iconData = {}
			    iconData.typeid = rewardAry[4][2]
			    iconData.num = rewardAry[4][3]
			    iconData.power = rewardAry[4][1]
			    if self.rewardImg4.uiIcon == nil then
				    self.rewardImg4.uiIcon = UIIcon.new(self.rewardImg4, iconData, true, self, nil, true)
			    else
				    self.rewardImg4.uiIcon:updateData(iconData)
			    end
		        self.rewardImg4:setVisible(true)
                self.rewardImg4.uiIcon:setNameFontSize(18)
                self.rewardImg4.uiIcon:setNameTxtBg()
		        self.rewardImg4:setOpacity(0)
		    	local fadeIn = cc.FadeIn:create(0.5)
		        self.rewardImg4:runAction(fadeIn)
		    end
	    end)

		local dt = cc.DelayTime:create(0.1)
		topPanel:runAction(cc.Sequence:create(dt,icon23Callfunc,dt,icon14Callfunc))

    else
   		 for i=1,#rewardAry do
		    local iconData = {}
		    iconData.typeid = rewardAry[i][2]
		    iconData.num = rewardAry[i][3]
		    iconData.power = rewardAry[i][1]
		    if self["rewardImg" .. i].uiIcon == nil then
			    self["rewardImg" .. i].uiIcon = UIIcon.new(self["rewardImg" .. i], iconData, true, self, nil, true)
		    else
			    self["rewardImg" .. i].uiIcon:updateData(iconData)
		    end
            self["rewardImg" .. i].uiIcon:setNameFontSize(18)
            self["rewardImg" .. i].uiIcon:setNameTxtBg()
	        self["rewardImg" .. i]:setVisible(true)
	    end
    end
    --[[
	
    --]]
	

	local freeTime  = self.proxy:getMartialFreeTime(self.myData.activityId)


	self.priceAry = {}
	local onePrice = tonumber(StringUtils:jsonDecode(config.expend)[1][4])
	local tenPrice = tonumber(StringUtils:jsonDecode(config.expend)[2][4])
	local fiftyPrice = tonumber(StringUtils:jsonDecode(config.expend)[3][4])
	table.insert(self.priceAry,onePrice)
	table.insert(self.priceAry,tenPrice)
	table.insert(self.priceAry,fiftyPrice)

	local onceBtn = self:getChildByName("topPanel/onceBtnPanel/btn")
	local onceBtnNumLab = self:getChildByName("topPanel/onceBtnPanel/numLab")
	local onceBtnIconImg = self:getChildByName("topPanel/onceBtnPanel/iconImg")
    local lab1 = onceBtn:getChildByName("lab1")
    local lab2 = onceBtn:getChildByName("lab2")
	-- local onceBtnFreeLab = self:getChildByName("topPanel/onceBtnPanel/freeLab")
    
	if freeTime > 0 then
		onceBtn:setTitleText(self:getTextWord(392003))
        TextureManager:updateButtonNormal(onceBtn, "images/newGui1/BtnMaxGreen1.png")
        TextureManager:updateButtonPressed(onceBtn, "images/newGui1/BtnMaxGreen2.png")
		onceBtnNumLab:setVisible(false)
		onceBtnIconImg:setVisible(false)
		-- onceBtnFreeLab:setVisible(true)
        lab1:setVisible(false)
        lab2:setVisible(false)
	else
		onceBtn:setTitleText("")
        TextureManager:updateButtonNormal(onceBtn, "images/newGui1/BtnMaxYellow1.png")
        TextureManager:updateButtonPressed(onceBtn, "images/newGui1/BtnMaxYellow2.png")
		onceBtnNumLab:setVisible(true)
		onceBtnIconImg:setVisible(true)
		-- onceBtnFreeLab:setVisible(false)
		onceBtnNumLab:setString(onePrice)
        lab1:setVisible(true)
        lab2:setVisible(true)
	end

	local tenBtnNumLab = self:getChildByName("topPanel/tenBtnPanel/numLab")
	tenBtnNumLab:setString(tenPrice)
	local fiftyBtnNumLab = self:getChildByName("topPanel/fiftyBtnPanel/numLab")
	fiftyBtnNumLab:setString(fiftyPrice)


end
function MartialMainPanel:chooseTypeHandler( sender )
	-- print(sender.tag)
	if self.isLearning == true then
		self:showSysMessage(self:getTextWord(392012))
		return
	end
	self.selectedTag = sender.tag


	self:updateTypeReward(self.selectedTag,true)

    local effectName = "rgb-wxt-lv"
    if self._type[self.selectedTag] == 1 then
        effectName = "rgb-wxt-lv"
    elseif self._type[self.selectedTag] == 2 then
        effectName = "rgb-wxt-lan"
    elseif self._type[self.selectedTag] == 3 then
        effectName = "rgb-wxt-zi"
    elseif self._type[self.selectedTag] == 4 then
        effectName = "rgb-wxt-huang"
    end
    
    local effect = self:createUICCBLayer(effectName, self:getChildByName("topPanel"))
	local size = sender:getContentSize()
    effect:setLocalZOrder(1024)
	effect:setPosition(sender:getPosition())
end

function MartialMainPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveUpPanel(topPanel, tabsPanel, GlobalConfig.topTabsHeight)
end
function MartialMainPanel:registerEvents()
	MartialMainPanel.super.registerEvents(self)
	local onceBtn = self:getChildByName("topPanel/onceBtnPanel/btn")
	onceBtn.tag = 1
	local tenBtn = self:getChildByName("topPanel/tenBtnPanel/btn")
	tenBtn.tag = 2
	local fifty = self:getChildByName("topPanel/fiftyBtnPanel/btn")
	fifty.tag = 3
	self:addTouchEventListener(onceBtn,self.learnOnce)
	self:addTouchEventListener(tenBtn,self.learnTen)
	self:addTouchEventListener(fifty,self.learnFifty)

end
function MartialMainPanel:learnOnce( sender,num )
	if self.isLearning == true then
		self:showSysMessage(self:getTextWord(392012))
		return
	end
	local freeTime  = self.proxy:getMartialFreeTime(self.myData.activityId)
	local free
	if freeTime > 0 then
		free = 0
	end
	local times =  num or free or 1
	-- print(times)
	----[[
	if times == 0 then
		local sendData = {}
		sendData.activityId = self.myData.activityId
		sendData.times = times
		sendData.type = self.moniData[self.selectedTag]
		self.proxy:onTriggerNet230032Req(sendData)
	else
    	local roleProxy = self:getProxy(GameProxys.Role)
	    local curNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
	    if self.priceAry[sender.tag] > curNum then
	        local parent = self:getParent()
	        local panel = parent.panel
	        if panel == nil then
	            local panel = UIRecharge.new(parent, self)
	            parent.panel = panel
	        else
	            panel:show()
	        end
	    else
        	local function sureFun()
				local sendData = {}
				sendData.activityId = self.myData.activityId
				sendData.times = times
				sendData.type = self.moniData[self.selectedTag]
				self.proxy:onTriggerNet230032Req(sendData)
        	end
        	local messageBox = self:showMessageBox(string.format(self:getTextWord(392007),self.priceAry[sender.tag],times),sureFun)
            messageBox:setGameSettingKey(GameConfig.PAYTWOCONFIRM)
	    end
	end

	
	--]]
end
function MartialMainPanel:learnTen(sender)
	self:learnOnce( sender,10 )
end
function MartialMainPanel:learnFifty(sender)
	self:learnOnce( sender,50 )
end
function MartialMainPanel:updateRankData()
	-- print("updateRankData================================")
	local myScoreLab = self:getChildByName("topPanel/myScoreLab")
	local myRankLab = self:getChildByName("topPanel/myRankLab")
	--排名
	local rankInfo = self.proxy:getRankInfoById(self.myData.activityId)
	if rankInfo.myRankInfo then
		myScoreLab:setString(rankInfo.myRankInfo.rankValue)
		
		if rankInfo.myRankInfo.rank == -1 then
			myRankLab:setString(self:getTextWord(360006))
		else
			myRankLab:setString(rankInfo.myRankInfo.rank)
		end
		myRankLab:setColor(rankInfo.myRankInfo.rank == -1 and ColorUtils.wordBadColor or ColorUtils.wordGoodColor)
	else
		myScoreLab:setString("")
		myRankLab:setString("")
	end
end

function MartialMainPanel:timestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
	local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return tab.year .. self:getTextWord(392009) .. tab.month .. self:getTextWord(392010) .. tab.day .. self:getTextWord(392011) .. hour ..":".. min
end
--学习成功后处理特效
function MartialMainPanel:afterMartiallearn(rewardList)
    local function handler()
	    local pauseFunc = function ()
			--刷新本页面与排行榜页面
			self.proxy:sendNotification(AppEvent.PROXY_UPDATE_MARTIALINFO)
			--获得物品特效
			AnimationFactory:playAnimationByName("GetGoodsEffect", rewardList)
			local dtTime = 1 + #rewardList*0.2
			local dt = cc.DelayTime:create(dtTime)
		    local rewardShowPanelCallfunc = cc.CallFunc:create(function ()
				self.rewardShowPanel:setVisible(true)
				self.isLearning = false
		    end)
		    local topPanel = self:getChildByName("topPanel")
			topPanel:runAction(cc.Sequence:create(dt,rewardShowPanelCallfunc))

	    end
	    self.rewardShowPanel:setVisible(false)
	    self.isLearning = true
		local effectMiddlePanel = self:getChildByName("topPanel/effectMiddlePanel")
		local learnEffect = self:createUICCBLayer("rgb-wxt-xuexi02", effectMiddlePanel,nil,nil,true,pauseFunc)
		local effectMiddlePanelSize = effectMiddlePanel:getContentSize()
		learnEffect:setPosition(effectMiddlePanelSize.width*0.495,effectMiddlePanelSize.height*0.4)
        
		local effectBottomPanel = self:getChildByName("topPanel/effectBottomPanel")
		learnEffect = self:createUICCBLayer("rgb-wxt-xuexi01", effectBottomPanel)
		local effectBottomPanelSize = effectBottomPanel:getContentSize()
		learnEffect:setPosition(effectBottomPanelSize.width*0.5,effectBottomPanelSize.height*0.5)
        --learnEffect:setLocalZOrder(10)

	end
	handler()

end