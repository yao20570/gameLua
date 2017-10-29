
CollectBlessView = class("CollectBlessView", BasicView)

function CollectBlessView:ctor(parent)
    CollectBlessView.super.ctor(self, parent)
end

function CollectBlessView:finalize()
    CollectBlessView.super.finalize(self)
end

function CollectBlessView:registerPanels()
    CollectBlessView.super.registerPanels(self)

    require("modules.collectBless.panel.CollectBlessPanel")
    self:registerPanel(CollectBlessPanel.NAME, CollectBlessPanel)
end

function CollectBlessView:initView()
    local panel = self:getPanel(CollectBlessPanel.NAME)
    panel:show()
end

function CollectBlessView:onShowView(msg, isInit, isAutoUpdate)
    CollectBlessView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(CollectBlessPanel.NAME)
    panel:show()
end

function CollectBlessView:updateList()
    local panel = self:getPanel(CollectBlessPanel.NAME)
    panel:updateList()
end