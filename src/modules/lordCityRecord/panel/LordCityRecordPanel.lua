
LordCityRecordPanel = class("LordCityRecordPanel", BasicPanel)
LordCityRecordPanel.NAME = "LordCityRecordPanel"

function LordCityRecordPanel:ctor(view, panelName)
    LordCityRecordPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function LordCityRecordPanel:finalize()
    LordCityRecordPanel.super.finalize(self)
end

function LordCityRecordPanel:initPanel()
	LordCityRecordPanel.super.initPanel(self)
    self:addTabControl()
end

function LordCityRecordPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(LordCityRecordSinglePanel.NAME, self:getTextWord(371001))  --个人
    self._tabControl:addTabPanel(LordCityRecordFullPanel.NAME, self:getTextWord(371002))  --全服
    self._tabControl:setTabSelectByName(LordCityRecordSinglePanel.NAME)
    self:setTitle(true,"lordCityRecord",true)
end

function LordCityRecordPanel:onClosePanelHandler()
	self.view:dispatchEvent(LordCityRecordEvent.HIDE_SELF_EVENT)
end


