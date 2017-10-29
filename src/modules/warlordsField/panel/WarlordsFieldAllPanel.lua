------------全部战场
WarlordsFieldAllPanel = class("WarlordsFieldAllPanel", BasicPanel)
WarlordsFieldAllPanel.NAME = "WarlordsFieldAllPanel"

function WarlordsFieldAllPanel:ctor(view, panelName)
    WarlordsFieldAllPanel.super.ctor(self, view, panelName)

end

function WarlordsFieldAllPanel:finalize()
    WarlordsFieldAllPanel.super.finalize(self)
end

function WarlordsFieldAllPanel:initPanel()
	WarlordsFieldAllPanel.super.initPanel(self)
	self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)

	local data = self._battleActivityProxy:onGetFightReports(1)
	self._uiFightInfosPanel = UIFightInfosPanel.new(self,data,nil,1)
end

function WarlordsFieldAllPanel:registerEvents()
	WarlordsFieldAllPanel.super.registerEvents(self)

	local signBtn = self:getChildByName("PanelDown/signBtn")
	self:addTouchEventListener(signBtn, self.onBtnClickHandle)

	local signBtn = self:getChildByName("PanelTop/tipBtn")
	self:addTouchEventListener(signBtn, self.showTips)

	self.Label_title = self:getChildByName("PanelTop/Label_title")
	self.Label_count = self:getChildByName("PanelTop/Label_count")
end

function WarlordsFieldAllPanel:showTips(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
    local line = {}
    local lines = {}
    for i=1,18 do
        local foneS = ColorUtils.tipSize20
        local color = ColorUtils.commonColor.MiaoShu
        if i == 1 or i == 8 or i == 11 then
            foneS = ColorUtils.tipSize24
            color = ColorUtils.commonColor.FuBiaoTi
        end
    	line[i] = {{content = self:getTextWord(280151+i), foneSize = foneS, color = color}}
    	table.insert(lines, line[i])
    end
    uiTip:setAllTipLine(lines)
end

function WarlordsFieldAllPanel:onBtnClickHandle()
	local id = self._battleActivityProxy:onGetWorloardsActId()
	self._battleActivityProxy:onTriggerNet330001Req({activityId = id})
	--self:dispatchEvent(WarlordsFieldEvent.HIDE_SELF_EVENT)
end

function WarlordsFieldAllPanel:onShowHandler()
	local data = self._battleActivityProxy:onGetFightReports(1)
	self._uiFightInfosPanel:updateData(data)
	self:onComBatProgress()
end

function WarlordsFieldAllPanel:onComBatProgress()
	-- local data = self._battleActivityProxy:onGetCombatProgress()
	-- local status = false
	-- if data.showState == 1 then
	-- 	self.Label_title:setString(self:getTextWord(330000))
	-- 	self.Label_count:setString(data.totalRound.."/"..data.allRound)
	-- 	status = true
	-- elseif data.showState == 2 then
	-- 	self.Label_title:setString(self:getTextWord(330001))

		-- if self.roundTime == nil then
		-- 	self.firstTime = os.time()
		-- 	self.roundTime  = data.roundTime
		-- end
		-- self:onUpdateTime()
		-- TimerManager:add(1000, self.onUpdateTime, self)
		--self.Label_count:setString(TimeUtils:getStandardFormatTimeString(data.roundTime))
	-- 	status = true
	-- end
	-- self.Label_title:setVisible(status)
	-- self.Label_count:setVisible(status)
end

function WarlordsFieldAllPanel:onUpdateTime()
	-- local time = self.firstTime  +  self.roundTime - os.time()
	-- if time > 0 then
	-- 	self.Label_count:setString(time)
	-- else
	-- 	TimerManager:remove(self.onUpdateTime,self)
	-- 	self.roundTime = nil
	-- end
end

function WarlordsFieldAllPanel:update()
	local data = self._battleActivityProxy:onGetCombatProgress()
	local status = false
	if data.showState == 1 then
		self.Label_title:setString(self:getTextWord(330000))
		self.Label_count:setString(data.totalRound.."/"..data.allRound)
		status = true
	elseif data.showState == 2 then
		self.Label_title:setString(self:getTextWord(330001))
		local time = self._battleActivityProxy:getRemainTime("coldDownTimeKeyqxzl")
		self.Label_count:setString(TimeUtils:getStandardFormatTimeString(time))
		status = true
	end
	self.Label_title:setVisible(status)
	self.Label_count:setVisible(status)
    NodeUtils:alignNodeL2R(self.Label_title, self.Label_count, 0)
end

function WarlordsFieldAllPanel:onHideHandler()
	-- TimerManager:remove(self.onUpdateTime,self)
end