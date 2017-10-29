
LegionGiftView = class("LegionGiftView", BasicView)

function LegionGiftView:ctor(parent)
    LegionGiftView.super.ctor(self, parent)
end

function LegionGiftView:finalize()
    LegionGiftView.super.finalize(self)
end

function LegionGiftView:registerPanels()
    LegionGiftView.super.registerPanels(self)

    require("modules.legionGift.panel.LegionGiftPanel")
    self:registerPanel(LegionGiftPanel.NAME, LegionGiftPanel)
end

function LegionGiftView:onShowView(extraMsg, isInit, isAutoUpdate)
	LegionGiftView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
	local panel = self:getPanel(LegionGiftPanel.NAME)
    panel:show()
end