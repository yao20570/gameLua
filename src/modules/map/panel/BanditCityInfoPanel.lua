-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
BanditCityInfoPanel = class("BanditCityInfoPanel", BasicPanel)
BanditCityInfoPanel.NAME = "BanditCityInfoPanel"

function BanditCityInfoPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    BanditCityInfoPanel.super.ctor(self, view, panelName,500, layer)
    
    self:setUseNewPanelBg(true)
end

function BanditCityInfoPanel:finalize()
    if self.UICityInfoPanel then
        self.UICityInfoPanel:finalize()
    end
    BanditCityInfoPanel.super.finalize(self)
end

function BanditCityInfoPanel:initPanel()
    BanditCityInfoPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(361))
    self:setLocalZOrder(20)
end

function BanditCityInfoPanel:registerEvents()
    BanditCityInfoPanel.super.registerEvents(self)
end

function BanditCityInfoPanel:onClosePanelHandler()
    self:hide()
end

function BanditCityInfoPanel:onHideHandler()
end

function BanditCityInfoPanel:onShowHandler(data)
    -- local eventId = data.eventId
    -- local panditMonster = ConfigDataManager:getConfigById(ConfigData.PanditMonsterConfig, eventId)
    -- panditMonster.chapter = 1
    -- data._info = panditMonster
    
    if data._info then
        local title = data._info.lv .. "级" .. data._info.name
        self:setTitle(true, title)
    end

    
    self.data = data
    if self.UICityInfoPanel then
        self.UICityInfoPanel:updateData(data,9)
    else
        self.UICityInfoPanel = UICityInfoPanel.new(self, data, 9, self.onCallback)
    end
end

function BanditCityInfoPanel:onCallback()
    local panel = self:getPanel(BanditPanel.NAME)
    panel:show(self.data)
    self:onClosePanelHandler()
end