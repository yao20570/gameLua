
StationView = class("StationView", BasicView)

function StationView:ctor(parent)
    StationView.super.ctor(self, parent)
end

function StationView:finalize()
    StationView.super.finalize(self)
end

function StationView:registerPanels()
    StationView.super.registerPanels(self)

    require("modules.station.panel.StationPanel")
    self:registerPanel(StationPanel.NAME, StationPanel)

end

function StationView:initView()
    -- local panel = self:getPanel(StationPanel.NAME)
    -- panel:show()
end

function StationView:setSolidertime(time)
	local panel = self:getPanel(StationPanel.NAME)
	if panel:isVisible() == true then
        panel:setSolidertime(time)
    end
end

function StationView:hideModuleHandler()
	self:dispatchEvent(StationEvent.HIDE_SELF_EVENT, {})
end

function StationView:onShowView(extraMsg, isInit, isAutoUpdate)
    StationView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(StationPanel.NAME)
    panel:show(extraMsg)
end