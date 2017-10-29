
VipBoxView = class("VipBoxView", BasicView)

function VipBoxView:ctor(parent)
    VipBoxView.super.ctor(self, parent)
end

function VipBoxView:finalize()
    VipBoxView.super.finalize(self)
end

function VipBoxView:registerPanels()
    VipBoxView.super.registerPanels(self)

    require("modules.vipBox.panel.VipBoxPanel")
    self:registerPanel(VipBoxPanel.NAME, VipBoxPanel)

    require("modules.vipBox.panel.VipBoxBuyPanel")
    self:registerPanel(VipBoxBuyPanel.NAME, VipBoxBuyPanel)

    
end

function VipBoxView:initView()

end

function VipBoxView:onShowView(extraMsg, isInit, isAutoUpdate)
	VipBoxView.super.onShowView(self,extraMsg, isInit, false)
    local function delyShow()
        local panel = self:getPanel(VipBoxPanel.NAME)
        panel:show()
        panel:onBoxTouch({boxType = 101})
    end
    TimerManager:addOnce(30,delyShow,self)
end

function VipBoxView:updatePanelResp()
    local panel = self:getPanel(VipBoxPanel.NAME)
    panel:updatePanel()
end

