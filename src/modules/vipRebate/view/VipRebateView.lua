
VipRebateView = class("VipRebateView", BasicView)

function VipRebateView:ctor(parent)
    VipRebateView.super.ctor(self, parent)
end

function VipRebateView:finalize()
    VipRebateView.super.finalize(self)
end

function VipRebateView:registerPanels()
    VipRebateView.super.registerPanels(self)
    
    require("modules.vipRebate.panel.VipRebatePanel")
    self:registerPanel(VipRebatePanel.NAME, VipRebatePanel)
    require("modules.vipRebate.panel.VipRebateMainPanel")
    self:registerPanel(VipRebateMainPanel.NAME, VipRebateMainPanel)
    require("modules.vipRebate.panel.VipGrandTotalPanel")
    self:registerPanel(VipGrandTotalPanel.NAME, VipGrandTotalPanel)
    
end

function VipRebateView:initView()
    -- local panel = self:getPanel(VipRebatePanel.NAME)
    -- panel:show()
end

function VipRebateView:onShowView(msg, isInit, isAutoUpdate)
    VipRebateView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(VipRebatePanel.NAME)
    panel:show()
end

function VipRebateView:updatePanelResp()
    local panel = self:getPanel(VipRebateMainPanel.NAME)
    panel:updateThisPanel()
    panel = self:getPanel(VipGrandTotalPanel.NAME)
    panel:updateThisPanel()
end

-- function VipRebateView:onShowView(msg, isInit, isAutoUpdate)
--     VipRebateView.super.onShowView(self, msg, isInit, false)
--     self:updatePanelResp()
--  end