
OpenServerGiftView = class("OpenServerGiftView", BasicView)

function OpenServerGiftView:ctor(parent)
    OpenServerGiftView.super.ctor(self, parent)
end

function OpenServerGiftView:finalize()
    OpenServerGiftView.super.finalize(self)
end

function OpenServerGiftView:registerPanels()
    OpenServerGiftView.super.registerPanels(self)

    require("modules.openServerGift.panel.OpenServerGiftPanel")
    self:registerPanel(OpenServerGiftPanel.NAME, OpenServerGiftPanel)

    require("modules.openServerGift.panel.OpenServerGiftPanel")
    self:registerPanel(OpenServerGiftPanel.NAME, OpenServerGiftPanel)
end
function OpenServerGiftView:onShowView(extraMsg, isInit, isAutoUpdate)
	OpenServerGiftView.super.onShowView(self,extraMsg, isInit,false)
    local panel = self:getPanel(OpenServerGiftPanel.NAME)
    panel:show()
end
function OpenServerGiftView:initView()
    -- local panel = self:getPanel(mainPanel.NAME)
    -- panel:show()
end

function OpenServerGiftView:updaOpenServerGiftView(sender)
    local panel = self:getPanel(OpenServerGiftPanel.NAME)
    panel:updateOpenServerView(sender)
end