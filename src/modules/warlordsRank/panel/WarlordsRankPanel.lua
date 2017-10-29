
WarlordsRankPanel = class("WarlordsRankPanel", BasicPanel)
WarlordsRankPanel.NAME = "WarlordsRankPanel"

function WarlordsRankPanel:ctor(view, panelName)
    WarlordsRankPanel.super.ctor(self, view, panelName,true)
    self:setUseNewPanelBg(true)
end

function WarlordsRankPanel:finalize()
    WarlordsRankPanel.super.finalize(self)
end

function WarlordsRankPanel:initPanel()
	WarlordsRankPanel.super.initPanel(self)

	self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(WarlordsRankPerPanel.NAME, self:getTextWord(280177))
    self._tabControl:addTabPanel(WarlordsRankLegionPanel.NAME, self:getTextWord(280178))

    self._tabControl:setTabSelectByName(WarlordsRankPerPanel.NAME)
    self:setTitle(true,"rank", true)
end

function WarlordsRankPanel:onClosePanelHandler()
    self:dispatchEvent(WarlordsRankEvent.HIDE_SELF_EVENT)
end
