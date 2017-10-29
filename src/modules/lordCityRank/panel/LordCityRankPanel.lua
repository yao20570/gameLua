
LordCityRankPanel = class("LordCityRankPanel", BasicPanel)
LordCityRankPanel.NAME = "LordCityRankPanel"

function LordCityRankPanel:ctor(view, panelName)
    LordCityRankPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function LordCityRankPanel:finalize()
    LordCityRankPanel.super.finalize(self)
end

function LordCityRankPanel:initPanel()
	LordCityRankPanel.super.initPanel(self)	
    self:addTabControl()
end

function LordCityRankPanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(LordCityRankSinglePanel.NAME, self:getTextWord(371003))
    self._tabControl:addTabPanel(LordCityRankLegionPanel.NAME, self:getTextWord(371004))
    self._tabControl:setTabSelectByName(LordCityRankSinglePanel.NAME)
    self:setTitle(true,"lordCityRank",true)
end


function LordCityRankPanel:onClosePanelHandler()
	self.view:dispatchEvent(LordCityRankEvent.HIDE_SELF_EVENT)
end



