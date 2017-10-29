
HeadAndPendantPanel = class("HeadAndPendantPanel", BasicPanel)
HeadAndPendantPanel.NAME = "HeadAndPendantPanel"

function HeadAndPendantPanel:ctor(view, panelName)
    HeadAndPendantPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function HeadAndPendantPanel:finalize()
    HeadAndPendantPanel.super.finalize(self)
end

function HeadAndPendantPanel:initPanel()
	HeadAndPendantPanel.super.initPanel(self)
	self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(HeadSettingPanel.NAME, self:getTextWord(1430))
    self._tabControl:addTabPanel(PendantSettingPanel.NAME, self:getTextWord(1431))
    self._tabControl:addTabPanel(TitleSettingPanel.NAME , self:getTextWord(592))
    self._tabControl:addTabPanel(TopFramePanel.NAME , self:getTextWord(1439))
    self._tabControl:setTabSelectByName(HeadSettingPanel.NAME)
    self:setTitle(true, "setting", true)

    -- self:setBgType(ModulePanelBgType.BLACKFULL)
end
function HeadAndPendantPanel:setOldSelectIndex(index)
	index = index or 1
	self._tabControl:setOldSelectIndex(index)
end

function HeadAndPendantPanel:registerEvents()
	HeadAndPendantPanel.super.registerEvents(self)
end

function HeadAndPendantPanel:onClosePanelHandler()

    self:dispatchEvent(HeadAndPendantEvent.HIDE_SELF_EVENT)
end