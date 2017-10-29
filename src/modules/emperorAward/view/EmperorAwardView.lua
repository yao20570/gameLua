
EmperorAwardView = class("EmperorAwardView", BasicView)

function EmperorAwardView:ctor(parent)
    EmperorAwardView.super.ctor(self, parent)
end

function EmperorAwardView:finalize()
    EmperorAwardView.super.finalize(self)
end

function EmperorAwardView:registerPanels()
    EmperorAwardView.super.registerPanels(self)

    require("modules.emperorAward.panel.EmperorAwardPanel")
    self:registerPanel(EmperorAwardPanel.NAME, EmperorAwardPanel)
end

function EmperorAwardView:initView()

end

function EmperorAwardView:onOpenView()
    local panel = self:getPanel(EmperorAwardPanel.NAME)
    panel:show()
end

function EmperorAwardView:updatePanel()
	local panel = self:getPanel(EmperorAwardPanel.NAME)
	panel:show() 
end
function EmperorAwardView:updateInfos()
	local panel = self:getPanel(EmperorAwardPanel.NAME)
	panel:onShowHandler() 
end
