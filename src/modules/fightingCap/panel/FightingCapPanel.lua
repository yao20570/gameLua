
FightingCapPanel = class("FightingCapPanel", BasicPanel)
FightingCapPanel.NAME = "FightingCapPanel"

function FightingCapPanel:ctor(view, panelName)
    FightingCapPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function FightingCapPanel:finalize()
    FightingCapPanel.super.finalize(self)
end

function FightingCapPanel:initPanel()
	FightingCapPanel.super.initPanel(self)
	self:setBgType(ModulePanelBgType.NONE)
	
    self:setTitle(true,"fightCap", true) --战斗力
end

--发送关闭系统消息
function FightingCapPanel:onClosePanelHandler()
    self.view:dispatchEvent(FightingCapEvent.HIDE_SELF_EVENT)
end