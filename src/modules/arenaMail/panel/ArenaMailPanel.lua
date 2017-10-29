
ArenaMailPanel = class("ArenaMailPanel", BasicPanel)
ArenaMailPanel.NAME = "ArenaMailPanel"

function ArenaMailPanel:ctor(view, panelName)
    ArenaMailPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function ArenaMailPanel:finalize()
    ArenaMailPanel.super.finalize(self)
end

function ArenaMailPanel:initPanel()
	ArenaMailPanel.super.initPanel(self)
	self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(ArenaMailPerPanel.NAME, self:getTextWord(1814))
    self._tabControl:addTabPanel(ArenaMailAllPanel.NAME, self:getTextWord(1815))
    self:setTitle(true,"yanwuchangReport",true)
    self:setBgType(ModulePanelBgType.NONE)
end

function ArenaMailPanel:setOpenModule()
	self._tabControl:changeTabSelectByName(ArenaMailPerPanel.NAME)
end

function ArenaMailPanel:onClosePanelHandler()
	self.view:hideModuleHandler()
end