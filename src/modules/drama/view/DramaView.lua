
DramaView = class("DramaView", BasicView)

function DramaView:ctor(parent)
    DramaView.super.ctor(self, parent)
end

function DramaView:finalize()
    DramaView.super.finalize(self)
end

function DramaView:registerPanels()
    DramaView.super.registerPanels(self)

    require("modules.drama.panel.DramaPanel")
    self:registerPanel(DramaPanel.NAME, DramaPanel)
end

function DramaView:initView()
    local panel = self:getPanel(DramaPanel.NAME)
    panel:show()
end