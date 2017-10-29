
RechargeView = class("RechargeView", BasicView)

function RechargeView:ctor(parent)
    RechargeView.super.ctor(self, parent)
end

function RechargeView:finalize()
    RechargeView.super.finalize(self)
end

function RechargeView:registerPanels()
    RechargeView.super.registerPanels(self)

    require("modules.recharge.panel.RechargePanel")
    self:registerPanel(RechargePanel.NAME, RechargePanel)
end

function RechargeView:initView()
    local panel = self:getPanel(RechargePanel.NAME)
    panel:show()
end

function RechargeView:updateRechargeInfo()
    local panel = self:getPanel(RechargePanel.NAME)
    if panel:isVisible() == true then
    	panel:updateRechargeInfo()
    end
end

function RechargeView:hideModuleHandler()
    self:dispatchEvent(RechargeEvent.HIDE_SELF_EVENT, {})
end

--------------------------------------------------------------------
-- 重写onShowView(),用于每次打开panel都执行onShowHandler()
function RechargeView:onShowView(extraMsg, isInit)
    RechargeView.super.onShowView(self,extraMsg, isInit, true)
end