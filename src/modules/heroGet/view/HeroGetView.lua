
HeroGetView = class("HeroGetView", BasicView)

function HeroGetView:ctor(parent)
    HeroGetView.super.ctor(self, parent)
end

function HeroGetView:finalize()
    HeroGetView.super.finalize(self)
end

function HeroGetView:registerPanels()
    HeroGetView.super.registerPanels(self)

    require("modules.heroGet.panel.HeroGetPanel")
    self:registerPanel(HeroGetPanel.NAME, HeroGetPanel)

    require("modules.heroGet.panel.HeroPreviewPanel")
    self:registerPanel(HeroPreviewPanel.NAME, HeroPreviewPanel)
end

function HeroGetView:initView()
--    local panel = self:getPanel(HeroGetPanel.NAME)
--    panel:show()
end

function HeroGetView:onShowView(extraMsg, isInit, isAutoUpdate)
    HeroGetView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
    local panel = self:getPanel(HeroGetPanel.NAME)
    panel:show(extraMsg)
end

function HeroGetView:showResolveView(data)
	local panel = self:getPanel(HeroPreviewPanel.NAME)
	panel:show(data)
end

function HeroGetView:hideResolveView()
	local panel = self:getPanel(HeroPreviewPanel.NAME)
	panel:hide()
end