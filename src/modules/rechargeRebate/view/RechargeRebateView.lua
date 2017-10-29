
RechargeRebateView = class("RechargeRebateView", BasicView)

function RechargeRebateView:ctor(parent)
    RechargeRebateView.super.ctor(self, parent)
end

function RechargeRebateView:finalize()
    RechargeRebateView.super.finalize(self)
end

function RechargeRebateView:registerPanels()
    RechargeRebateView.super.registerPanels(self)

    require("modules.rechargeRebate.panel.RechargeRebatePanel")
    self:registerPanel(RechargeRebatePanel.NAME, RechargeRebatePanel)
end
function RechargeRebateView:onShowView(extraMsg, isInit)
    RechargeRebateView.super.onShowView(self,extraMsg, isInit, true)
end
function RechargeRebateView:initView()
    local panel = self:getPanel(RechargeRebatePanel.NAME)
    panel:show()
end
function RechargeRebateView:afterTurn(data)
    local panel = self:getPanel(RechargeRebatePanel.NAME)
    panel:afterTurn(data)
end
function RechargeRebateView:infosUpdate(data)
    local panel = self:getPanel(RechargeRebatePanel.NAME)
    panel:updateRechargeRebateView(data)
end
function RechargeRebateView:after230050(data)
    local panel = self:getPanel(RechargeRebatePanel.NAME)
    panel:after230050(data)
end


