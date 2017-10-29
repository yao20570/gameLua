
WarlordsSignPanel = class("WarlordsSignPanel", BasicPanel)
WarlordsSignPanel.NAME = "WarlordsSignPanel"

function WarlordsSignPanel:ctor(view, panelName)
    WarlordsSignPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function WarlordsSignPanel:finalize()
    WarlordsSignPanel.super.finalize(self)
end

function WarlordsSignPanel:initPanel()
	WarlordsSignPanel.super.initPanel(self)
	self:setTitle(true,"sign", true)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)

	self.Label_status = self:getChildByName("PanelTop/Label_status")
	self.Label_count = self:getChildByName("PanelTop/Label_count")
	self.Label_Tatal = self:getChildByName("PanelTop/Label_Tatal")

	self.listview = self:getChildByName("PanelTop/ListView")
	self.btnJoinlegion = self:getChildByName("PanelDown/btnJoinlegion")
	self.btnSign = self:getChildByName("PanelDown/btnSign")

	self.btnCancle = self:getChildByName("PanelDown/btnCancle")
	self.btnLook = self:getChildByName("PanelDown/btnLook")

	self.btnInfo = self:getChildByName("PanelTop/btnInfo")

	self:setBgType(ModulePanelBgType.NONE)
end

function WarlordsSignPanel:registerEvents()
	WarlordsSignPanel.super.registerEvents(self)

	self:addTouchEventListener(self.btnJoinlegion, self.onBtnClickHandle)
	self:addTouchEventListener(self.btnSign, self.onBtnClickHandle)

	self:addTouchEventListener(self.btnCancle, self.onBtnClickHandle)
	self:addTouchEventListener(self.btnLook, self.onBtnClickHandle)
	self:addTouchEventListener(self.btnInfo, self.showTips)
end

function WarlordsSignPanel:showTips(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
    local line = {}
    local lines = {}
    for i=1,11 do
        local foneS = ColorUtils.tipSize20
        local color = ColorUtils.commonColor.MiaoShu
        if i == 5 then
            foneS = ColorUtils.tipSize24
            color = ColorUtils.commonColor.FuBiaoTi
        end
    	line[i] = {{content = self:getTextWord(280140+i), foneSize = foneS, color = color}}
    	table.insert(lines, line[i])
    end
    uiTip:setAllTipLine(lines)
end

function WarlordsSignPanel:onClosePanelHandler()
	TimerManager:remove(self.onUpdateCoolTime,self)
    self:hide()
    local panel = self:getPanel(WarlordsPanel.NAME)

    if panel:isVisible() then
    	panel:onWarlordsOpen()
    else
    	panel:show()
    end
end

-- function WarlordsSignPanel:hide()
-- 	self.super.hide(self)
-- end

function WarlordsSignPanel:onBtnClickHandle(sender)
	if sender == self.btnSign then   --报名
		local panel = self:getPanel(WarlordsTeamPanel.NAME)
		panel:show() 
	elseif sender == self.btnJoinlegion then  --所有军团信息
		local panel = self:getPanel(WarlordsLegionJoinPanel.NAME)
		panel:show()
	elseif sender == self.btnCancle then   --取消报名
		local function okFunction()
			local data = {}
			data.type = 1
			data.activityId = self._battleActivityProxy:onGetWorloardsActId()
			data.fightInfos = {}
			self._battleActivityProxy:onTriggerNet330003Req(data)
		end
		self:showMessageBox("取消报名有1分钟冷却时间，确定取消报名吗？", okFunction)
		
	else
		self._battleActivityProxy:onTriggerNet330004Req({activityId = self._battleActivityProxy:onGetWorloardsActId()})   --查看阵型
	end
end

function WarlordsSignPanel:onShowHandler()
	self:onGetMylegionsList()
end

function WarlordsSignPanel:onSetSignBtnStatus(status,notStatus)
	self.btnSign:setVisible(status)
	self.btnLook:setVisible(notStatus)
	self.btnCancle:setVisible(notStatus)
end

function WarlordsSignPanel:onSetBtnTimeStatus(status)
	local Label_10 = self.btnSign:getChildByName("Label_10")
	local time = self.btnSign:getChildByName("time")
	Label_10:setVisible(status)
	time:setVisible(status)
end

function WarlordsSignPanel:onUpdateCoolTime()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	local restTime = self._battleActivityProxy:getRemainTime(id.."enrollCoolTime")
	local time = self.btnSign:getChildByName("time")
	if restTime > 0 then
		time:setString(TimeUtils:getStandardFormatTimeString(restTime))
	else
		NodeUtils:setEnable(self.btnSign, true)
		self:onSetBtnTimeStatus(false)
		TimerManager:remove(self.onUpdateCoolTime,self)
	end
end

function WarlordsSignPanel:onGetMylegionsList()
	local statusData = self._battleActivityProxy:onGetWorloardsStatus()
	local isEnroll = self._battleActivityProxy:onGetIsEnroll()

	self:onSetBtnTimeStatus(false)
	if statusData.legionMelee.state == 1 then  --报名中才可点击
		NodeUtils:setEnable(self.btnSign, true)
		if isEnroll == 1 then --已报名
			self:onSetSignBtnStatus(false,true)
		else
			local id = self._battleActivityProxy:onGetWorloardsActId()
			local restTime = self._battleActivityProxy:getRemainTime(id.."enrollCoolTime")
			if restTime > 0 then
				self:onSetBtnTimeStatus(true)
				NodeUtils:setEnable(self.btnSign, false)
				TimerManager:add(1000, self.onUpdateCoolTime, self)
			end
			self:onSetSignBtnStatus(true,false)
		end
	else
		NodeUtils:setEnable(self.btnSign, false)
		self:onSetSignBtnStatus(true,false)
	end
	
	if isEnroll == 1 then  --已报名
		self.Label_status:setString("已报名")
	else
		self.Label_status:setString("未报名")
	end

	local data = self._battleActivityProxy:getMyLegionInfosList()
	local allMemberNum = data.allMemberNum
	local serverData = data.memberInfos
	self.Label_count:setString(#serverData)
	self.Label_Tatal:setString("/"..allMemberNum)

	if #serverData == 0 then
		serverData = {}
	end
	self:renderListView(self.listview, serverData, self, self.registerItemEvents, false, false, 0)
    
    local posY = self:getChildByName("PanelTop/Image_5"):getPositionY()
    local num = #serverData
    local offsetHeight = num * 60
    local listHeight = self.listview:getContentSize().height
    if offsetHeight > listHeight then
        offsetHeight = listHeight 
    end

    self:getChildByName("PanelTop/imgBottomLine"):setPositionY(posY - offsetHeight - 21)
end

function WarlordsSignPanel:registerItemEvents(item,data,index)
	item.data = data
	local Label_time = item:getChildByName("Label_time")
	local Label_fight  = item:getChildByName("Label_fight")
	local Label_level = item:getChildByName("Label_level")
	local Label_name  = item:getChildByName("Label_name")
	local itemBgImg  = item:getChildByName("bgImg")
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end
	
	Label_time:setString(TimeUtils:setTimestampToString5(data.enrollTime))
	Label_name:setString(data.name)
	Label_level:setString(data.level)
	Label_fight:setString(StringUtils:formatNumberByK(data.capacity))

end

