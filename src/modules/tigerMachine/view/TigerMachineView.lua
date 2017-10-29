
TigerMachineView = class("TigerMachineView", BasicView)

function TigerMachineView:ctor(parent)
    TigerMachineView.super.ctor(self, parent)
end

function TigerMachineView:finalize()
    TigerMachineView.super.finalize(self)
end

function TigerMachineView:registerPanels()
    TigerMachineView.super.registerPanels(self)

    require("modules.tigerMachine.panel.TigerMachinePanel")
    self:registerPanel(TigerMachinePanel.NAME, TigerMachinePanel)
end

function TigerMachineView:initView()
    local panel = self:getPanel(TigerMachinePanel.NAME)
    panel:show()
end

function TigerMachineView:onShowView(extraMsg, isInit, isAutoUpdate)
	TigerMachineView.super.onShowView(self,extraMsg, isInit,false)
    local panel = self:getPanel(TigerMachinePanel.NAME)
    panel:show()
end

function TigerMachineView:updatePanelResp(data)
    local panel = self:getPanel(TigerMachinePanel.NAME)
    panel:updatePanel(data)
end