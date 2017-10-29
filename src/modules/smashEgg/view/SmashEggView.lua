
SmashEggView = class("SmashEggView", BasicView)

function SmashEggView:ctor(parent)
    SmashEggView.super.ctor(self, parent)
end

function SmashEggView:finalize()
    SmashEggView.super.finalize(self)
end

function SmashEggView:registerPanels()
    SmashEggView.super.registerPanels(self)

    require("modules.smashEgg.panel.SmashEggPanel")
    self:registerPanel(SmashEggPanel.NAME, SmashEggPanel)
end

-- function SmashEggView:initView()
--     local panel = self:getPanel(SmashEggPanel.NAME)
--     panel:show()
-- end

function SmashEggView:updateValue()
    local panel = self:getPanel(SmashEggPanel.NAME)
    panel:updateValue()
end

function SmashEggView:onShowView(msg, isInit, isAutoUpdate)
    SmashEggView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(SmashEggPanel.NAME)
    panel:show()
end

function SmashEggView:onSmashEggResp( rewardList )
    local panel = self:getPanel(SmashEggPanel.NAME)
    panel:onSmashEggResp( rewardList )
end