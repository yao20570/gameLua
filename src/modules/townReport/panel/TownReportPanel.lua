-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
TownReportPanel = class("TownReportPanel", BasicPanel)
TownReportPanel.NAME = "TownReportPanel"

function TownReportPanel:ctor(view, panelName)
    TownReportPanel.super.ctor(self, view, panelName, true)
    self:setUseNewPanelBg(true)
end

function TownReportPanel:finalize()
    TownReportPanel.super.finalize(self)
end

function TownReportPanel:initPanel()
	TownReportPanel.super.initPanel(self)
    self:setTitle(true,"report",true)
    self:setBgType(ModulePanelBgType.NONE)

    self:addTabControl()
end

function TownReportPanel:registerEvents()
	TownReportPanel.super.registerEvents(self)

end

function TownReportPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function TownReportPanel:addTabControl()
    local tabControl = UITabControl.new(self)
    tabControl:addTabPanel(TownAllReportPanel.NAME, self:getTextWord(471015))
    tabControl:addTabPanel(TownLegionReportPanel.NAME, self:getTextWord(471016))

    tabControl:changeTabSelectByName(TownAllReportPanel.NAME)

    self._tabControl = tabControl

end
