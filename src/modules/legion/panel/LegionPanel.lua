
LegionPanel = class("LegionPanel", BasicPanel)
LegionPanel.NAME = "LegionPanel"

function LegionPanel:ctor(view, panelName)
    LegionPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function LegionPanel:finalize()
    LegionPanel.super.finalize(self)
end

function LegionPanel:initPanel()
	LegionPanel.super.initPanel(self)
	
    self:setTitle(true,"legion", true)

end

function LegionPanel:onClosePanelHandler()
    self:dispatchEvent(LegionEvent.HIDE_SELF_EVENT, {})
end

function LegionPanel:setFirstPanelShow()
end

