-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
DungeonXCityInfoPanel = class("DungeonXCityInfoPanel", BasicPanel)
DungeonXCityInfoPanel.NAME = "DungeonXCityInfoPanel"

function DungeonXCityInfoPanel:ctor(view, panelName)
    DungeonXCityInfoPanel.super.ctor(self, view, panelName,500)

    self:setUseNewPanelBg(true)
end

function DungeonXCityInfoPanel:finalize()
    if self.UICityInfoPanel then
        self.UICityInfoPanel:finalize()
    end
    DungeonXCityInfoPanel.super.finalize(self)
end

function DungeonXCityInfoPanel:initPanel()
    DungeonXCityInfoPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(350005))
    self:setLocalZOrder(20)
end

function DungeonXCityInfoPanel:registerEvents()
    DungeonXCityInfoPanel.super.registerEvents(self)
end

function DungeonXCityInfoPanel:onClosePanelHandler()
    self:hide()
end

function DungeonXCityInfoPanel:onHideHandler()
end

function DungeonXCityInfoPanel:onShowHandler(data)
    self.data = data
    if self.UICityInfoPanel then
        self.UICityInfoPanel:updateData(data)
    else
        self.UICityInfoPanel = UICityInfoPanel.new(self, data, 6, self.onCallback)
    end
end

function DungeonXCityInfoPanel:onCallback()
    local panel = self:getPanel(DungeonXCityPanel.NAME)
    panel:show(self.data)
    self:onClosePanelHandler()
end
