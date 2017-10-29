
WarlordsFieldPanel = class("WarlordsFieldPanel", BasicPanel)
WarlordsFieldPanel.NAME = "WarlordsFieldPanel"

function WarlordsFieldPanel:ctor(view, panelName)
    WarlordsFieldPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function WarlordsFieldPanel:finalize()
    WarlordsFieldPanel.super.finalize(self)
end

function WarlordsFieldPanel:initPanel()
	WarlordsFieldPanel.super.initPanel(self)

	self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(WarlordsFieldAllPanel.NAME, "全 服")
    self._tabControl:addTabPanel(WarlordsFieldLegionPanel.NAME, self:getTextWord(3021))
    self._tabControl:addTabPanel(WarlordsFieldPerPanel.NAME, "个 人")

    self._tabControl:setTabSelectByName(WarlordsFieldAllPanel.NAME)
    self:setTitle(true,"fightGround", true)
end

function WarlordsFieldPanel:registerEvents()
	WarlordsFieldPanel.super.registerEvents(self)
end

function WarlordsFieldPanel:onClosePanelHandler()
    self:dispatchEvent(WarlordsFieldEvent.HIDE_SELF_EVENT)
end
