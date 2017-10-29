---------设置阵型
WarlordsTeamPanel = class("WarlordsTeamPanel", BasicPanel)
WarlordsTeamPanel.NAME = "WarlordsTeamPanel"

function WarlordsTeamPanel:ctor(view, panelName)
    WarlordsTeamPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function WarlordsTeamPanel:finalize()
	if self.UITeamMiPanel then
	    self.UITeamMiPanel:finalize()
	end
    WarlordsTeamPanel.super.finalize(self)
end

function WarlordsTeamPanel:initPanel()
	WarlordsTeamPanel.super.initPanel(self)
	self:setTitle(true,"sign", true)
	self:setBgType(ModulePanelBgType.TEAM)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
end

function WarlordsTeamPanel:onClosePanelHandler()
    self:hide()
end

-- function WarlordsTeamPanel:registerEvents()
-- 	WarlordsTeamPanel.super.registerEvents(self)

-- 	-- self:addTouchEventListener(self.btnAttand, self.onBtnClickHandle)
-- 	-- self:addTouchEventListener(self.btnCancle, self.onBtnClickHandle)
-- 	-- self:addTouchEventListener(self.btnLook, self.onBtnClickHandle)
-- end

-- function WarlordsTeamPanel:onBtnClickHandle(sender)
-- 	if sender == self.btnAttand then       --查看军团信息
-- 		local panel = self:getPanel(WarlordsLegionJoinPanel.NAME)
-- 		panel:show()
-- 	elseif sender == self.btnCancle then   --取消报名
-- 		local data = {}
-- 		data.type = 1
-- 		data.activityId = self._battleActivityProxy:onGetWorloardsActId()
-- 		data.fightInfos = {}
-- 		self._battleActivityProxy:onTriggerNet330003Req(data)
-- 	else
-- 	end
-- end

function WarlordsTeamPanel:onShowHandler()
	local data 
	-- local isEnroll = self._battleActivityProxy:onGetIsEnroll()
	-- if isEnroll == 1 then  --已报名
	-- 	self.PanelDown:setVisible(true)
	-- 	data = self._battleActivityProxy:onGetFightInfos()  --阵型数据
	-- 	if not data then  --没数据  向服务器请求
	-- 		local id = self._battleActivityProxy:onGetWorloardsActId()
	-- 		self._battleActivityProxy:onTriggerNet330004Req({activityId = id})
	-- 	end
	-- else
	-- 	self.PanelDown:setVisible(false)
	-- end

	if self.UITeamMiPanel then
		self.UITeamMiPanel:onUpdateData(data,7)
	else
		-- self.UITeamMiPanel = UITeamMiPanel.new(self,data,7,self.onIsInColdTime,self:topAdaptivePanel())
        local topPanel = self:topAdaptivePanel()
        topPanel.topOffset = GlobalConfig.topAdaptive
		self.UITeamMiPanel = UITeamMiPanel.new(self,data,7,self.onIsInColdTime, topPanel)
	end
end

-- function WarlordsTeamPanel:onGetFightInfos()
-- 	local data = self._battleActivityProxy:onGetFightInfos()
-- 	self.UITeamMiPanel:onUpdateData(data,7)
-- end

function WarlordsTeamPanel:onIsInColdTime()  --是否在冷却时间
	local id = self._battleActivityProxy:onGetWorloardsActId()
	local time = self._battleActivityProxy:getRemainTime(id.."enrollCoolTime")
	if time > 0 then   --在冷却时间
		return true
	end
	return false
end

function WarlordsTeamPanel:onSignHandle(serverData,saveData, curFight)
	local function call()
		local data = {}
	    data.type = 0
		data.activityId = self._battleActivityProxy:onGetWorloardsActId()
		data.fightInfos = serverData
		data.fightTeamCapacity = curFight
		self._battleActivityProxy:onTriggerNet330003Req(data)
		self._battleActivityProxy:onSaveData(saveData)
		self:hide()
	end
	self:showMessageBox("你确定要报名吗？", call)
end