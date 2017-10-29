
PartsView = class("PartsView", BasicView)

function PartsView:ctor(parent)
    PartsView.super.ctor(self, parent)
end

function PartsView:finalize()
    PartsView.super.finalize(self)
end

function PartsView:registerPanels()
    PartsView.super.registerPanels(self)

    require("modules.parts.panel.PartsPanel")
    self:registerPanel(PartsPanel.NAME, PartsPanel)
    
    require("modules.parts.panel.PartsMainPanel")
    self:registerPanel(PartsMainPanel.NAME, PartsMainPanel)
    
    require("modules.parts.panel.PartsPagePanel")
end

--系统要显示的界面
function PartsView:initView()
    local syspanel = self:getPanel(PartsPanel.NAME)
    syspanel:show()
    local mainpanel = self:getPanel(PartsMainPanel.NAME)
    mainpanel:show()
    mainpanel:setHtmlStr("html/help_fit.html")
end

--关闭系统
function PartsView:onCloseView()
    PartsView.super.onCloseView(self)
end
--打开系统
function PartsView:onShowView(extraMsg, isInit)
    PartsView.super.onShowView(self,extraMsg, isInit,true)
end