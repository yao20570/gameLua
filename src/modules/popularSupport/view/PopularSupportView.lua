
PopularSupportView = class("PopularSupportView", BasicView)

function PopularSupportView:ctor(parent)
    PopularSupportView.super.ctor(self, parent)
end

function PopularSupportView:finalize()
    PopularSupportView.super.finalize(self)
end

function PopularSupportView:registerPanels()
    PopularSupportView.super.registerPanels(self)

    require("modules.popularSupport.panel.PopularSupportPanel")
    self:registerPanel(PopularSupportPanel.NAME, PopularSupportPanel)
end

function PopularSupportView:initView()
    local panel = self:getPanel(PopularSupportPanel.NAME)
    panel:show()
end

function PopularSupportView:openView()
    local panel = self:getPanel(PopularSupportPanel.NAME)
    panel:show()
end

function PopularSupportView:updatePanel(dely)
    local panel = self:getPanel(PopularSupportPanel.NAME)
    panel:updatePanel(dely) 
end

function PopularSupportView:getAction()
    local panel = self:getPanel(PopularSupportPanel.NAME)
    panel:getAction() 
end

function PopularSupportView:refreshAction()
    local panel = self:getPanel(PopularSupportPanel.NAME)
    panel:refreshAction() 
end

function PopularSupportView:updateNums()
    local panel = self:getPanel(PopularSupportPanel.NAME)
    panel:updateNums()
end