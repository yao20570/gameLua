
RedPacketView = class("RedPacketView", BasicView)

function RedPacketView:ctor(parent)
    RedPacketView.super.ctor(self, parent)
end

function RedPacketView:finalize()
    RedPacketView.super.finalize(self)
end

function RedPacketView:registerPanels()
    RedPacketView.super.registerPanels(self)

    require("modules.redPacket.panel.RedPacketPanel")
    self:registerPanel(RedPacketPanel.NAME, RedPacketPanel)
end

function RedPacketView:initView()
    local panel = self:getPanel(RedPacketPanel.NAME)
    panel:show()
end

function RedPacketView:onShowView(msg, isInit, isAutoUpdate)
    RedPacketView.super.onShowView(self, msg, isInit, false)

    local panel = self:getPanel(RedPacketPanel.NAME)
    panel:show()
end

function RedPacketView:updateView(data)
    local panel = self:getPanel(RedPacketPanel.NAME)
    panel:initView(data)
end

function RedPacketView:showPkgInfoView(data)
    local panel = self:getPanel(RedPacketPanel.NAME)
    panel:showPkgInfoView(data)
end