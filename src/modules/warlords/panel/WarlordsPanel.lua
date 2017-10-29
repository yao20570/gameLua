
WarlordsPanel = class("WarlordsPanel", BasicPanel)
WarlordsPanel.NAME = "WarlordsPanel"

function WarlordsPanel:ctor(view, panelName)
    WarlordsPanel.super.ctor(self, view, panelName,true)
    self:setUseNewPanelBg(true)
end

function WarlordsPanel:finalize()
    WarlordsPanel.super.finalize(self)
end

function WarlordsPanel:initPanel()
	WarlordsPanel.super.initPanel(self)
	self:setTitle(true,"warlords", true)
	self:setBgType(ModulePanelBgType.WARLORDS)
    self:updateTopTitleBg("images/common/SPActivityHead.png")
    self:setCloseMultiBtn(true)

	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)

	local Panel_1 = self:getChildByName("Panel_1")
	self.Label_second = Panel_1:getChildByName("Label_second")
	self.btnSign = Panel_1:getChildByName("btnSign")
	self.btnRank = Panel_1:getChildByName("btnRank")
	self.Image_sign = Panel_1:getChildByName("Image_sign")
	self.Label_time = Panel_1:getChildByName("Label_time")
	self.Label_people = Panel_1:getChildByName("Label_people")
	self.btnFight = Panel_1:getChildByName("btnFight")
	self.Label_failed = Panel_1:getChildByName("Label_failed")
	self.Label_next = Panel_1:getChildByName("Label_next")
	self.Label_nextTime = Panel_1:getChildByName("Label_nextTime")
	self.Label_now = Panel_1:getChildByName("Label_now")
	
end

function WarlordsPanel:doLayout()
	self:onAdaptiveBgImg()
end

function WarlordsPanel:onAdaptiveBgImg()
	--local panelBg = self:getChildByName("bgPanel")
	--panelBg:setBackGroundImage("bg/warlords/bg.pvr.ccz")
	--TextureManager:addTextureKey2TopModule("bg/warlords/bg.pvr.ccz")
	---- TextureManager:updateImageViewFile(panelBg,"bg/warlords/bg.pvr.ccz")
	--local topAdaptivePanel = self:topAdaptivePanel()
	--NodeUtils:adaptivePanelBg(panelBg,GlobalConfig.downHeight-6,topAdaptivePanel)
end

function WarlordsPanel:onClosePanelHandler()
    self:dispatchEvent(WarlordsEvent.HIDE_SELF_EVENT)
end

function WarlordsPanel:registerEvents()
	WarlordsPanel.super.registerEvents(self)

	self:addTouchEventListener(self.btnSign, self.onTouchBtnHandle)
	self:addTouchEventListener(self.btnRank, self.onTouchBtnHandle)
	self:addTouchEventListener(self.btnFight, self.onTouchBtnHandle)
end

function WarlordsPanel:onTouchBtnHandle(sender)
	local id = self._battleActivityProxy:onGetWorloardsActId()
	if sender == self.btnSign then
		self._battleActivityProxy:onTriggerNet330001Req({activityId = id})
	elseif sender == self.btnFight then  --战场
		self._battleActivityProxy:onTriggerNet330005Req({activityId = id})
	else
		self:dispatchEvent(WarlordsEvent.SHOW_OTHER_EVENT,ModuleName.WarlordsRankModule)
	end
end

function WarlordsPanel:onShowHandler()
	local data = self._battleActivityProxy:onGetWorloardsStatus()
	if data then
		self:onWarlordsOpen()
	end
end

function WarlordsPanel:onHideHandler()
	self:onWarlordsClose()
end

function WarlordsPanel:onTimeCheck()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	self.restTime = self._battleActivityProxy:getRemainTime(id.."nextStateTime")
	if self.restTime > 0 then  --下次剩余时间
		self.Label_second:setVisible(true)
		self.Label_time:setVisible(true)
		self:updateTime()
		TimerManager:add(1000, self.updateTime, self)
	end
end

function WarlordsPanel:onWarlordsOpen()
	TimerManager:remove(self.updateTime,self)
	local data = self._battleActivityProxy:onGetWorloardsStatus()
	local legionMelee = data.legionMelee
	local id = self._battleActivityProxy:onGetWorloardsActId()

	self.Label_next:setVisible(false)
	self.Label_nextTime:setVisible(false)
	self.Label_now:setVisible(false)
	self.Label_second:setVisible(false)
	self.Label_time:setVisible(false)
	self.Label_failed:setVisible(false)
	

	if legionMelee.state == 1 then --报名中
		self.btnSign:setVisible(true)
		self.btnFight:setVisible(false)
		self.Label_second:setString( self:getTextWord(330002) )
		self:onTimeCheck()
	elseif legionMelee.state == 2 then
		self.btnSign:setVisible(false)
		self.btnFight:setVisible(true)
		self.Label_second:setString(self:getTextWord(330003))
		self:onTimeCheck()
	else
		self.btnSign:setVisible(false)
		self.btnFight:setVisible(true)
	end

	self.restTime = self._battleActivityProxy:getRemainTime(id.."nextStateTime")

	self.Image_sign:setVisible(self._battleActivityProxy:onGetIsEnroll() >= 1 and legionMelee.state ~= 0)

	if legionMelee.stateReason == 1 then  --活动开启失败
		self.Label_failed:setVisible(true)
		self.Label_next:setVisible(true)
		self.Label_nextTime:setVisible(true)
		self.Label_nextTime:setString(TimeUtils:setTimestampToString(legionMelee.nextDate))
		return
	end

	self.Label_people:setVisible(legionMelee.legionEnrollNum > 0 and legionMelee.state ~= 0)
	if legionMelee.legionEnrollNum > 0 then  --军团已报名
		self.Label_people:setString(string.format(self:getTextWord(330004), legionMelee.legionEnrollNum))
	end





	if legionMelee.state == 0 then --未开启
		--self.Label_second:setVisible(false)
		--self.Label_time:setVisible(false)
		--self.Label_failed:setVisible(false)
		--self.Label_people:setVisible(false)
		self.Label_next:setVisible(true)
		self.Label_nextTime:setVisible(true)
		self.Label_nextTime:setString(TimeUtils:setTimestampToString(legionMelee.nextDate))
	elseif legionMelee.state == 3 then --混战中
		--self.Label_second:setVisible(false)
		--self.Label_time:setVisible(false)
		--self.Label_failed:setVisible(false)
		--self.Label_people:setVisible(false)
		self.Label_now:setVisible(true)
	end

	-- if legionMelee.stateReason == 1 then  --活动开启失败
	-- 	self.Label_failed:setVisible(true)
	-- -- else
	-- -- 	self.Label_failed:setVisible(false)
	-- end
end

function WarlordsPanel:updateTime()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	self.restTime = self._battleActivityProxy:getRemainTime(id.."nextStateTime")
	if self.restTime > 0 then
		self.Label_time:setString(TimeUtils:getStandardFormatTimeString(self.restTime))
	else
		--local id = self._battleActivityProxy:onGetWorloardsActId()
		--self._battleActivityProxy:onTriggerNet330000Req({activityId = id})
		--TimerManager:remove(self.updateTime,self)
		--self.Label_time:setVisible(false)
		self:onWarlordsClose()
	end
end

function WarlordsPanel:onWarlordsClose()
	TimerManager:remove(self.updateTime,self)
	self.Label_time:setVisible(false)
	self.Label_second:setVisible(false)
end