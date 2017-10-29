
GainView = class("GainView", BasicView)

function GainView:ctor(parent)
    GainView.super.ctor(self, parent)
end

function GainView:finalize()
    GainView.super.finalize(self)
end

function GainView:registerPanels()
    GainView.super.registerPanels(self)

    require("modules.gain.panel.GainPanel")
    self:registerPanel(GainPanel.NAME, GainPanel)

    require("modules.gain.panel.GainHonourPanel")
    self:registerPanel(GainHonourPanel.NAME, GainHonourPanel)
    
    require("modules.gain.panel.GainInfoPanel")
    self:registerPanel(GainInfoPanel.NAME, GainInfoPanel)

end

function GainView:initView()
    local panel = self:getPanel(GainPanel.NAME)
    panel:show()
end
function GainView:onShowView(extraMsg, isInit)
    GainView.super.onShowView(self,extraMsg, isInit, true)
end
--更新buffer数据
function GainView:updateData(data)
    if self._bufferInfo == nil then
        self._bufferInfo = {}
    end 
    self._bufferInfo = data
    local infoPanel = self:getPanel(GainInfoPanel.NAME)
    infoPanel:updateData(data)
end 
--关闭系统
function GainView:onCloseView()
    GainView.super.onCloseView(self)
end


function GainView:onItemBufferUpdate(data)
    local panel = self:getPanel(GainInfoPanel.NAME)
    if panel:isVisible() then
        panel:onItemBufferUpdate()
    end
    local panel = self:getPanel(GainHonourPanel.NAME)
    if panel:isVisible() then
        panel:onItemBufferUpdate(data)
    end
end
