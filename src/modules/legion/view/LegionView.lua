
LegionView = class("LegionView", BasicView)

function LegionView:ctor(parent)
    LegionView.super.ctor(self, parent)
end

function LegionView:finalize()
    LegionView.super.finalize(self)
end

function LegionView:registerPanels()
    LegionView.super.registerPanels(self)
    require("modules.legion.panel.LegionInfoPanel")
    self:registerPanel(LegionInfoPanel.NAME, LegionInfoPanel)
    require("modules.legion.panel.LegionJobEditPanel")
    self:registerPanel(LegionJobEditPanel.NAME, LegionJobEditPanel)
    require("modules.legion.panel.LegionEditPanel")
    self:registerPanel(LegionEditPanel.NAME, LegionEditPanel)
end

function LegionView:initView()
    local panel = self:getPanel(LegionInfoPanel.NAME)
    panel:show()
end



function LegionView:onLegionInfoUpdate()
    local panel = self:getPanel(LegionInfoPanel.NAME)
    if panel:isVisible() == true then
        panel:onLegionInfoUpdate()
    end
    
end


-- 显示搜索军团结果
function LegionView:onSearchLegionInfos(data)

end
-- 更新成员列表，包括盟主转让
function LegionView:onLegionMemberUpdate()
    local panel = self:getPanel(LegionInfoPanel.NAME)
    if panel:isVisible() == true then
        panel:onLegionInfoUpdate()
        return
    end
end

function LegionView:showOtherModule(moduleName)
    self:dispatchEvent(LegionEvent.SHOW_OTHER_EVENT,moduleName)
end

--编辑军团返回的职位
function LegionView:onLegionEditResp()
    -- body
    local panel = self:getPanel(LegionEditPanel.NAME)
    if panel:isVisible() == true then
        panel:hide()
        self:showSysMessage(self:getTextWord(3119))
    end

end

function LegionView:hideModuleHandler()
    self:dispatchEvent(LegionEvent.HIDE_SELF_EVENT, {})
end

-- --------------------------------------------------------------------
-- -- 重写onShowView(),用于每次打开panel都执行onShowHandler()
-- function LegionView:onShowView(extraMsg, isInit)
--     TaskView.super.onShowView(self,extraMsg, isInit, true)
-- end
