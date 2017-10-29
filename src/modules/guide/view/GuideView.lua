
GuideView = class("GuideView", BasicView)

function GuideView:ctor(parent)
    GuideView.super.ctor(self, parent)
end

function GuideView:finalize()
    GuideView.super.finalize(self)
end

function GuideView:registerPanels()
    GuideView.super.registerPanels(self)

    require("modules.guide.panel.GuidePanel")
    self:registerPanel(GuidePanel.NAME, GuidePanel)
end

function GuideView:initView()
    local panel = self:getPanel(GuidePanel.NAME)
    panel:show()
end
--更新对话框信息, 1、头像 openIconName == nil
function GuideView:updateDialogueInfo(info, callback)
    local panel = self:getPanel(GuidePanel.NAME)
    panel:updateDialogueInfo(info, callback)
end
--@arrowDir 箭头的方向 配置的时候，强制设置
function GuideView:updateAreaClick(widget, callback, info, isMove, arrowDir)
    local panel = self:getPanel(GuidePanel.NAME)
    panel:updateAreaClick(widget, callback, info, isMove, arrowDir)
end

-- 剧情
function GuideView:updatePlot(plotData, callback)
    local panel = self:getPanel(GuidePanel.NAME)
    panel:updatePlot(plotData, callback)
end


function GuideView:resetView(isShowFlag)
    local panel = self:getPanel(GuidePanel.NAME)
    panel:resetPanel(isShowFlag)
end

function GuideView:onShowView(extraMsg, isInit, isAutoUpdate)
    GuideView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
    local panel = self:getPanel(GuidePanel.NAME)
    
    -- if GuideManager:getCurGuideId() ~= GuideManager.EndGuideId then
    --     panel:setSkipBtnVisible(false)
    -- else
        panel:setSkipBtnVisible(true)
    -- end
end

function GuideView:onCloseView()
    GuideView.super.onCloseView(self)
    
    local panel = self:getPanel(GuidePanel.NAME)
    panel:resetGuide()

    panel:onHideHandler()
end

function GuideView:onEnterScene()
    local panel = self:getPanel(GuidePanel.NAME)
    panel:onEnterScene()
end

function GuideView:updateIconPos(widget, x, y)
    local panel = self:getPanel(GuidePanel.NAME)
    panel:updateIconPos(widget, x, y)
end

function GuideView:resetIcon(isShowFlag)
    local panel = self:getPanel(GuidePanel.NAME)
    panel:setTaskIconVisible(isShowFlag)
end