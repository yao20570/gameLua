--[[
城主战：防守/进攻弹窗
]]

LordCityDefeatPanel = class("LordCityDefeatPanel", BasicPanel)
LordCityDefeatPanel.NAME = "LordCityDefeatPanel"

function LordCityDefeatPanel:ctor(view, panelName)
    LordCityDefeatPanel.super.ctor(self, view, panelName, 720)

end

function LordCityDefeatPanel:finalize()
    LordCityDefeatPanel.super.finalize(self)
end

function LordCityDefeatPanel:initPanel()
	LordCityDefeatPanel.super.initPanel(self)
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
end

function LordCityDefeatPanel:registerEvents()
	LordCityDefeatPanel.super.registerEvents(self)

	local teamSetBtn = self:getChildByName("mainPanel/infoPanel/teamSetBtn")  --设置阵型/撤回防守
	self:addTouchEventListener(teamSetBtn,self.onTeamSetBtnTouch)
	self._teamSetBtn = teamSetBtn

	local iconImg = self:getChildByName("mainPanel/infoPanel/iconImg")	--元宝图片
	local needTxt = self:getChildByName("mainPanel/infoPanel/needTxt")	--休整费用
	local timeLab = self:getChildByName("mainPanel/infoPanel/timeLab")	--元宝图片
	local timeTxt = self:getChildByName("mainPanel/infoPanel/timeTxt")	--休整费用
	iconImg:setVisible(false)
	needTxt:setVisible(false)
	timeLab:setVisible(false)
	timeTxt:setVisible(false)

	self._listView = self:getChildByName("mainPanel/listView")
	local item = self._listView:getItem(0)
	item:setVisible(false)

	local closeBtn = self:getCloseBtn()  --弹窗界面的关闭按钮
	self:addTouchEventListener(closeBtn, self.onClosePanelHandler)
end

function LordCityDefeatPanel:onClosePanelHandler()
	-- print("...... 关闭防守列表界面 ")
	local panel = self:getPanel(LordCityBattlePanel.NAME)
	panel:onCityInfoUpdate()
	self:hide()
end

function LordCityDefeatPanel:onShowHandler()
	if self._listView then
		self._listView:jumpToTop()
	end

	self._cityId = self._lordCityProxy:getSelectCityId()
	self:showInfoByType()
	self:onDefTeamUpdate()
	self:updateInfoPanel()
end

-------------------------------------------------------------------------------
-- 协议数据更新
-------------------------------------------------------------------------------
function LordCityDefeatPanel:onDefMapUpdate(data)
	-- print("........... 协议数据更新 攻防。000  ")
	self:onShowHandler()
end

function LordCityDefeatPanel:onPlayerInfoUpdate()
	-- print("........... 360042协议数据更新玩家信息  ")
	self:updateInfoPanel()
end

function LordCityDefeatPanel:onDefTeamUpdate(data)  ---查看玩家阵型（暂时指自己的阵型）
	-- print("........... 更新设置部队状态  ")
	self._isHaveTeam = self._lordCityProxy:getIsHaveTeam()
	if self._isHaveTeam then
		self._teamSetBtn:setTitleText(self:getTextWord(370049))
	else
		self._teamSetBtn:setTitleText(self:getTextWord(370053))
	end
	self:updateInfoPanel()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function LordCityDefeatPanel:showInfoByType()
	self._showType = self._lordCityProxy:getCityState()
	local func = self["showInfoByType"..self._showType]
	if func then
		func(self)
	end

	local data = self._lordCityProxy:getDefenderInfoMap()
	self:renderListView(self._listView, data, self, self.renderItem)
end

function LordCityDefeatPanel:showInfoByType1()  --进攻方显示的内容
	self:setTitle(true,self:getTextWord(370035))
	self._teamSetBtn:setVisible(false)

	local y = self._teamSetBtn:getPositionY()
	self:setValuePosY(y)
end

function LordCityDefeatPanel:showInfoByType2()  --防守方显示的内容
	self:setTitle(true,self:getTextWord(370036))
	self._teamSetBtn:setVisible(true)

	local y = self._teamSetBtn:getPositionY() + self._teamSetBtn:getContentSize().height/2 + 12
	self:setValuePosY(y)
end

function LordCityDefeatPanel:setValuePosY(posY)
	local valueLab = self:getChildByName("mainPanel/infoPanel/valueLab")
	local valueTxt = self:getChildByName("mainPanel/infoPanel/valueTxt")
	valueLab:setPositionY(posY)
	valueTxt:setPositionY(posY)
end

-- -- 判定攻防状态  返回值stateType：1=进攻UI，2=防守UI
-- function LordCityDefeatPanel:getCityState()
-- 	local roleProxy = self:getProxy(GameProxys.Role)
-- 	local selfLegionName = roleProxy:getLegionName()
-- 	local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
	
-- 	local stateType
-- 	if selfLegionName == cityHost.hostLegion then
-- 		stateType = 2  --城池属于己方军团，提示防守
-- 	else
-- 		stateType = 1  --城池不属于己方军团，提示进攻
-- 	end
-- 	return stateType
-- end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function LordCityDefeatPanel:updateInfoPanel()
	-- local timeTxt = self:getChildByName("mainPanel/infoPanel/timeTxt")				--休整剩余时间
	local valueTxt = self:getChildByName("mainPanel/infoPanel/valueTxt")			--我的积分
	local bloodTxt = self:getChildByName("mainPanel/infoPanel/bloodTxt")			--城墙血量 richtext

	local playerInfo = self._lordCityProxy:getPlayerInfo(self._cityId)
	local score = rawget(playerInfo,"score") or 0
	valueTxt:setString(score)
	
	-- 城墙血量 富文本显示
	local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBattleConfig,"ID",self._cityId)
	local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
	local curHp = 0
	local maxHp = 0
	if cityHost.wallNowHp > 0 then  --城墙 HP
		local cityConfig = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityWallConfig,"ID",config.wallID)
		curHp = cityHost.wallNowHp
		maxHp = cityConfig.wallHp
	end

	local fontSize = 20
	local color1 = "#FFDCA0"
	local color2 = "#66ff00"
	local timeStr = {{{self:getTextWord(370075),fontSize,color1},{curHp,fontSize,color2},{"/"..maxHp,fontSize,color2},},}
	bloodTxt:setString("")
	local richLabel = bloodTxt.richLabel
	if richLabel == nil then
	    richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
	    bloodTxt:addChild(richLabel)
	    bloodTxt.richLabel = richLabel
	end
	richLabel:setString(timeStr)	


	bloodTxt:setVisible(true)
	if cityHost.bossNowHp > 0 then
		bloodTxt:setVisible(false)  --BOSS战阶段隐藏城墙血量显示
	end
end

function LordCityDefeatPanel:updateRestTime()
	local remainTime = self:getRemainTime()
	local timeLab = self:getChildByName("mainPanel/infoPanel/timeLab")				--休整剩余时间
	local timeTxt = self:getChildByName("mainPanel/infoPanel/timeTxt")				--休整剩余时间
	timeTxt:setString(remainTime.."s")
	
	--时间为0时候隐藏
	local isShow = true
	if remainTime <= 0 then
		isShow = false
	end
	timeLab:setVisible(isShow)
	timeTxt:setVisible(isShow)

end


function LordCityDefeatPanel:getRemainTime()
	local remainTime = 0
	if self._showType == 1 then
		remainTime = self._lordCityProxy:getRestAttRemainTime(self._cityId)
	elseif self._showType == 2 then
		remainTime = self._lordCityProxy:getRestDefRemainTime(self._cityId)
	end

	remainTime = remainTime or 0
	
	return remainTime
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 渲染
function LordCityDefeatPanel:renderItem(itemPanel, info)
	if itemPanel == nil or info == nil then
		return
	end
	itemPanel:setVisible(true)

	local iconImg = itemPanel:getChildByName("iconImg")
	local nameTxt = itemPanel:getChildByName("nameTxt")
	local levelTxt = itemPanel:getChildByName("levelTxt")
	local fightCapTxt = itemPanel:getChildByName("fightCapTxt")
	local fightBtn = itemPanel:getChildByName("fightBtn")
	
	-- 头像和挂件
	local headInfo = {}
	headInfo.pendant = nil
	headInfo.isCreatPendant = false
	headInfo.isCreatButton = false

	local name,level,capacity
	local config,monsterGroup
	if info.type == 1 then  --boss名字等级
		config = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityBossConfig,"ID",info.id)
		monsterGroup = ConfigDataManager:getConfigById(ConfigData.MonsterGroupConfig,config.mongroup)
		name = monsterGroup.name
		level = monsterGroup.lv
		capacity = info.capacity
		headInfo.icon = config.icon
		headInfo.preName1 = "monsterIcon"
		logger:info("boss!!!!!!!!!!!  %d",config.icon)

	elseif info.type == 3 then  --城墙名字等级
		config = ConfigDataManager:getInfoFindByOneKey(ConfigData.CityWallConfig,"ID",info.id)
		monsterGroup = ConfigDataManager:getConfigById(ConfigData.MonsterGroupConfig,config.mongroup)
		name = monsterGroup.name
		level = monsterGroup.lv
		capacity = info.capacity
		headInfo.icon = config.icon
		headInfo.preName1 = "monsterIcon"
		logger:info(" 城墙！！！！！！%d ",config.icon)

	else  --敌军是玩家
		logger:info("玩家！！！！！")
		name = info.name
		level = info.level		
		capacity = info.capacity
		headInfo.icon = info.icon
		headInfo.preName1 = "headIcon"
		-- headInfo.preName2 = "headPendant"

        local f64 = StringUtils:int64ToFixed64(info.id)
        headInfo.playerId = f64
	end
	nameTxt:setString(name)
	levelTxt:setString("Lv."..level)


	fightCapTxt:setString(StringUtils:formatNumberByK3(capacity))
	levelTxt:setPositionX(nameTxt:getPositionX() + nameTxt:getContentSize().width + 30)

	TextureManager:updateImageView(iconImg,"images/lordCity/none.png")


	local head = iconImg.head
	if head == nil then
	    head = UIHeadImg.new(iconImg,headInfo,self)
	    
	    iconImg.head = head
	else
	    head:updateData(headInfo)
	end

	if self._showType == 2 then
		fightBtn:setVisible(false)  --防守方不显示攻击按钮
		return
	else
		fightBtn:setVisible(true)
	end

	fightBtn.info = info
	if fightBtn.addEvent == nil then
		fightBtn.addEvent = true
		self:addTouchEventListener(fightBtn, self.onFightBtnTouch)
		return
	end
end

function LordCityDefeatPanel:clearRestTime() --清除休整CD
	if self._showType == nil or self._cityId == nil then
		return
	end
	local data = {type = self._showType-1,cityId = self._cityId}
	self._lordCityProxy:onTriggerNet360024Req(data)
end

-- 攻击按钮  打开设置阵型出战界面
function LordCityDefeatPanel:onFightBtnTouch(sender)
	if self:isVisible() == false then
		return
	end

	if self:isCanTouch() == false then
		return
	end

	local function callFunc()
		local data = {}
		data.type = 12
		data.info = sender.info
		local panel = self:getPanel(LordCityTeamSetPanel.NAME)
		panel:show(data)

		self:hide()
	end
	
	local readyRemainTime = self._lordCityProxy:getBattleReadyRemainTime(self._cityId)
	if readyRemainTime > 0 then
		self:showSysMessage(self:getTextWord(370058)) --准备阶段时间不为0不可攻击
		return
	end

	local changeRemainTime = self._lordCityProxy:getChangeRemainTime(self._cityId)
	if changeRemainTime > 0 then
		self:showSysMessage(self:getTextWord(370074)) --攻防CD倒计时不为0不可攻击
		return
	end

	local remainTime = self:getRemainTime()
	if remainTime > 0 then
		local config = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig,self._cityId)
		local needMoney = config.restCost * remainTime

		local function okCallBack()
			local function clearRestTime()	--清除休整CD
				self:clearRestTime()
			end

			sender.callFunc = clearRestTime
			sender.money = needMoney
			self:isShowRechargeUI(sender)
		end
		local str = string.format(self:getTextWord(370017),needMoney)
		local messageBox = self:showMessageBox(str,okCallBack)
		messageBox:setGameSettingKey(GameConfig.LORDCITYSPEND)

	else   --休整时间为0
		callFunc()
	end
end

-- 元宝不足则不能设置自动休整
function LordCityDefeatPanel:isCanSetRest()
	local remainTime = self:getRemainTime()
	if remainTime > 0 then
		local config = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig,self._cityId)
		local needMoney = config.restCost * remainTime

		local roleProxy = self:getProxy(GameProxys.Role)
		local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝
		if needMoney > haveGold then
			self:showSysMessage(self:getTextWord(370050))  --元宝不足则不能自动休整
			return false
		end
	end
	return true
end

function LordCityDefeatPanel:isCanTouch()  --是否有点击权限
	local isCanTouch = true

	local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
	if cityHost.cityState ~= 1 then
		self:showSysMessage(self:getTextWord(370083))
		isCanTouch = false
	else
		local playerInfo = self._lordCityProxy:getPlayerInfo(self._cityId)
		if playerInfo then
			local participate = rawget(playerInfo,"participate")
			if participate == 0 then
				self:showSysMessage(self:getTextWord(370063))
				isCanTouch = false
			end
		end
	end
	return isCanTouch
end

-- 设置阵型按钮  
function LordCityDefeatPanel:onTeamSetBtnTouch(sender)
	if self:isVisible() == false then
		return
	end

	if self:isCanTouch() == false then
		return
	end
	
	if self._isHaveTeam then  --已设置防守

		local restTime = self:getRemainTime()
		local config = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig,self._cityId)
		local needMoney = config.restCost * restTime
		
		local function revertTeam()
			local data = {cityId = self._cityId}
			self._lordCityProxy:onTriggerNet360019Req(data)
		end

		if restTime > 0 then
			-- 有休整CD,是否休整
			local function clearRestTime()	--清除休整CD
				self:clearRestTime()
			end

			local function okCallBack()  --打开设置阵型防守界面
				sender.callFunc = clearRestTime
				sender.money = needMoney
				self:isShowRechargeUI(sender)
			end

			local str = string.format(self:getTextWord(370017),needMoney)
			self:showMessageBox(str,okCallBack)
		else
			-- 撤回部队
			local str = self:getTextWord(370054)
			self:showMessageBox(str,revertTeam)
		end

	
	else  --未设置防守
		local restTime = self:getRemainTime()
		local config = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig,self._cityId)
		local needMoney = config.restCost * restTime
		
		local function callFunc()
			local data = {}
			data.type = 11
			data.info = sender.info
			local panel = self:getPanel(LordCityTeamSetPanel.NAME)
			panel:show(data)
			self:hide()
		end

		if restTime > 0 then
			local function clearRestTime()	--清除休整CD
				self:clearRestTime()
			end

			local function okCallBack()  --打开设置阵型防守界面
				sender.callFunc = clearRestTime
				sender.money = needMoney
				self:isShowRechargeUI(sender)
			end
			local str = string.format(self:getTextWord(370017),needMoney)
			local messageBox = self:showMessageBox(str,okCallBack)
			messageBox:setGameSettingKey(GameConfig.LORDCITYSPEND)
		else
			callFunc()
		end

	end

end

-- 是否弹窗元宝不足
function LordCityDefeatPanel:isShowRechargeUI(sender)
    -- body
    local needMoney = sender.money

    local roleProxy = self:getProxy(GameProxys.Role)
    local haveGold = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0--拥有元宝

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

-- 显示休整费用
function LordCityDefeatPanel:updateRestTimeNeedMoney()
	local iconImg = self:getChildByName("mainPanel/infoPanel/iconImg")	--元宝图片
	local needTxt = self:getChildByName("mainPanel/infoPanel/needTxt")	--休整费用

	local restTime = self:getRemainTime()
	local config = ConfigDataManager:getConfigById(ConfigData.CityBattleConfig,self._cityId)
	local needMoney = config.restCost * restTime
	if needMoney <= 0 then
		iconImg:setVisible(false)		
		needTxt:setVisible(false)
		return		
	end
	iconImg:setVisible(true)
	needTxt:setVisible(true)
	needTxt:setString(needMoney)

end

function LordCityDefeatPanel:update()
	self:updateRestTime()
	self:updateRestTimeNeedMoney()
end
