
PartsStrengthenView = class("PartsStrengthenView", BasicView)

function PartsStrengthenView:ctor(parent,extraMsg)
    PartsStrengthenView.super.ctor(self, parent)
    self._extraMsg = extraMsg
end

function PartsStrengthenView:finalize()
    PartsStrengthenView.super.finalize(self)
end

function PartsStrengthenView:registerPanels()
    PartsStrengthenView.super.registerPanels(self)

    require("modules.partsStrengthen.panel.PartsStrengthenPanel")
    self:registerPanel(PartsStrengthenPanel.NAME, PartsStrengthenPanel)
    
    -----
    require("modules.partsStrengthen.panel.PartsIntensifyPanel")
    self:registerPanel(PartsIntensifyPanel.NAME, PartsIntensifyPanel)
    require("modules.partsStrengthen.panel.PartsRemouldPanel")
    self:registerPanel(PartsRemouldPanel.NAME, PartsRemouldPanel)
    require("modules.partsStrengthen.panel.PartsEvolvePanel")
    self:registerPanel(PartsEvolvePanel.NAME, PartsEvolvePanel)
    
end

function PartsStrengthenView:initView()
    local panel = self:getPanel(PartsStrengthenPanel.NAME)
    panel:show()
end

------

--关闭系统
function PartsStrengthenView:onCloseView()
    PartsStrengthenView.super.onCloseView(self)
end

--打开系统
-- function PartsStrengthenView:onShowView(extraMsg, isInit)
    -- PartsStrengthenView.super.onShowView(self,extraMsg, isInit)
    -- local index = extraMsg.index
    -- local partsProxy = self:getProxy(GameProxys.Parts)
    -- extraMsg.data.configData = partsProxy:getDataFromOrdnanceConfig(extraMsg.data.parts)
    -- local data = extraMsg.data
    -- local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
    -- mainPanel:updatePanelInfo(extraMsg)
    -- self:updatePanelInfo(data)
-- end

function PartsStrengthenView:onOpenView(extraMsg)
    -- PartsStrengthenView.super.onShowView(self,extraMsg, isInit)
    local index = extraMsg.index
    local partsProxy = self:getProxy(GameProxys.Parts)
    extraMsg.data.configData = partsProxy:getDataFromOrdnanceConfig(extraMsg.data.parts)
    local data = extraMsg.data
    local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
    mainPanel:updatePanelInfo(extraMsg)
    self:updatePanelInfo(data)
end

--从服务器就受到数据
function PartsStrengthenView:onUpdateInfo(parts)
    if parts == nil then 
        self:updatePanelInfo()
        return 
    end
    local data = {}
    data.parts = parts
    local partsProxy = self:getProxy(GameProxys.Parts)
    data.configData = partsProxy:getDataFromOrdnanceConfig(parts)
    data.num =  1
    data.power =  GamePowerConfig.Ordnance
    data.typeid =  parts.typeid --配件的唯一标志ID
    
    self:updatePanelInfo(data)
end 
--更新panel
function PartsStrengthenView:updatePanelInfo(data)
    local intensifyPanel = self:getPanel(PartsIntensifyPanel.NAME)
    if intensifyPanel:isVisible() == true then
        intensifyPanel:updatePanelInfo(data)
    end 
    if data ~= nil then
        local mainPanel = self:getPanel(PartsStrengthenPanel.NAME)
        mainPanel:updateData(data)
        local remouldPanel = self:getPanel(PartsRemouldPanel.NAME)
        if remouldPanel:isVisible() == true then
            remouldPanel:updatePanelInfo(data)
        end 
        local evolvePanel = self:getPanel(PartsEvolvePanel.NAME)
        if evolvePanel:isVisible() == true then
            evolvePanel:updatePanelInfo(data)
        end 
    end 
end

function PartsStrengthenView:onUpdatePieceInfo()
    local evolvePanel = self:getPanel(PartsEvolvePanel.NAME)
    if evolvePanel:isVisible() == true then
        evolvePanel:onUpdatePieceInfo()
    end 
end

function PartsStrengthenView:updateRoleInfoHandler()
    -- body
    local intensifyPanel = self:getPanel(PartsIntensifyPanel.NAME)
    if intensifyPanel:isVisible() == true then
        intensifyPanel:updateRoleInfoHandler()
    end 
end

function PartsStrengthenView:updateStrengState(rs)
    local panel = self:getPanel(PartsIntensifyPanel.NAME)
    panel:updateStrengState(rs)
end

function PartsStrengthenView:partsChange()
    local panel = self:getPanel(PartsRemouldPanel.NAME)
    panel:partsChange()
end