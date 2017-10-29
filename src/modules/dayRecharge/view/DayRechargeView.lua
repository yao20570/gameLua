
DayRechargeView = class("DayRechargeView", BasicView)

function DayRechargeView:ctor(parent)
    DayRechargeView.super.ctor(self, parent)
end

function DayRechargeView:finalize()
    DayRechargeView.super.finalize(self)
end

function DayRechargeView:registerPanels()
    DayRechargeView.super.registerPanels(self)

    require("modules.dayRecharge.panel.DayRechargePanel")
    self:registerPanel(DayRechargePanel.NAME, DayRechargePanel)
end

function DayRechargeView:onShowView(msg, isInit, isAutoUpdate)
    local panel = self:getPanel(DayRechargePanel.NAME)
    panel:show()
end

function DayRechargeView:renderPanel( )
	local panel = self:getPanel(DayRechargePanel.NAME)
    panel:renderPanel()
end