
LegionHallView = class("LegionHallView", BasicView)

function LegionHallView:ctor(parent)
    LegionHallView.super.ctor(self, parent)
end

function LegionHallView:finalize()
    LegionHallView.super.finalize(self)
end

function LegionHallView:registerPanels()
    LegionHallView.super.registerPanels(self)

    require("modules.legionHall.panel.LegionHallPanel")
    self:registerPanel(LegionHallPanel.NAME, LegionHallPanel)
end

function LegionHallView:initView()
    local panel = self:getPanel(LegionHallPanel.NAME)
    panel:show()
    panel:setHtmlStr("html/help_legion.html")
end

function LegionHallView:hideModuleHandler()
    self:dispatchEvent(LegionHallEvent.HIDE_SELF_EVENT, {})
end


function LegionHallView:onShowView(extraMsg, isInit)
    LegionHallView.super.onShowView(self,extraMsg, isInit, true)
end

function LegionHallView:onHallInfoResp(data)
    -- body
    local panel = self:getPanel(LegionHallPanel.NAME)
    if panel:isVisible() == true then
        panel:onHallInfoResp(data)
    end
end
-- 捐献之后更新
function LegionHallView:onHallContributeResp(data)
    -- body
    local panel = self:getPanel(LegionHallPanel.NAME)
    panel:onHallContributeResp(data)
end

-- 捐献之后更新
function LegionHallView:updateRoleInfoHandler()
    -- body
    local panel = self:getPanel(LegionHallPanel.NAME)
    if panel:isVisible() == true then
        panel:updateRoleInfoHandler()
    end
end
