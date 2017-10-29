
GiftBagView = class("GiftBagView", BasicView)

function GiftBagView:ctor(parent)
    GiftBagView.super.ctor(self, parent)
end

function GiftBagView:finalize()
    GiftBagView.super.finalize(self)
end

function GiftBagView:registerPanels()
    GiftBagView.super.registerPanels(self)

    require("modules.giftBag.panel.GiftBagPanel")
    self:registerPanel(GiftBagPanel.NAME, GiftBagPanel)
end

function GiftBagView:onShowView(extraMsg, isInit, isAutoUpdate)
	GiftBagView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
	local panel = self:getPanel(GiftBagPanel.NAME)
    panel:show()
end
function GiftBagView:updateInfos()
	local panel = self:getPanel(GiftBagPanel.NAME)
    -- panel:updateAllInfo()
    panel:showGiftBagInfo()
end
--询问服务器礼包是否可以购买返回
function GiftBagView:doBuyAction(data)
    local panel = self:getPanel(GiftBagPanel.NAME)
    panel:doBuyAction(data)
end