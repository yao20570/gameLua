
VipRebatePanel = class("VipRebatePanel", BasicPanel)
VipRebatePanel.NAME = "VipRebatePanel"

function VipRebatePanel:ctor(view, panelName)
    VipRebatePanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function VipRebatePanel:finalize()
    VipRebatePanel.super.finalize(self)
end

function VipRebatePanel:initPanel()
	VipRebatePanel.super.initPanel(self)
	self:addTabControl()
end

function VipRebatePanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(VipRebateMainPanel.NAME, self:getTextWord(230121))
    self._tabControl:addTabPanel(VipGrandTotalPanel.NAME, self:getTextWord(230125))
    self._tabControl:changeTabSelectByName(VipRebateMainPanel.NAME)
    self._tabControl:setChainVisbale(true)
    self._tabControl:setChainPosition(86, 554)
    self:setTitle(true, "vipRebate", true)
    self:setBgType(ModulePanelBgType.ACTIVITY)

end

function VipRebatePanel:onShowHandler()
    local panel = self:getPanel(VipRebateMainPanel.NAME)
    panel:updateThisPanel()
    panel = self:getPanel(VipGrandTotalPanel.NAME)
    panel:updateThisPanel()
end

function VipRebatePanel:registerEvents()
	VipRebatePanel.super.registerEvents(self)
end

function VipRebatePanel:onClosePanelHandler()
	self:dispatchEvent(VipRebatePanel.HIDE_SELF_EVENT)
end