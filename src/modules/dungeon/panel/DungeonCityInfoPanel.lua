-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
DungeonCityInfoPanel = class("DungeonCityInfoPanel", BasicPanel)
DungeonCityInfoPanel.NAME = "DungeonCityInfoPanel"

function DungeonCityInfoPanel:ctor(view, panelName)
    DungeonCityInfoPanel.super.ctor(self, view, panelName,500)

    self:setUseNewPanelBg(true)
end

function DungeonCityInfoPanel:finalize()
    if self.UICityInfoPanel then
        self.UICityInfoPanel:finalize()
    end
    DungeonCityInfoPanel.super.finalize(self)
end

function DungeonCityInfoPanel:initPanel()
    DungeonCityInfoPanel.super.initPanel(self)
    self:setTitle(true,self:getTextWord(200110))
    self:setLocalZOrder(20)
    self._noCloseBtn = false
end

function DungeonCityInfoPanel:registerEvents()
    DungeonCityInfoPanel.super.registerEvents(self)
end

function DungeonCityInfoPanel:onClosePanelHandler()
    self._noCloseBtn = true
    self:hide()
end

function DungeonCityInfoPanel:onHideHandler()
    if self._noCloseBtn == true then
        return
    end
    self._noCloseBtn = false

    local dungeonMapPanel = self:getPanel(DungeonMapPanel.NAME)
    if dungeonMapPanel:isVisible() == true then
        dungeonMapPanel:onDungeonInfoFlush()
    end
end

function DungeonCityInfoPanel:onShowHandler(data)
    self.data = data
    if self.UICityInfoPanel then
        self.UICityInfoPanel:updateData(data)
    else
        self.UICityInfoPanel = UICityInfoPanel.new(self, data, 0, self.onCallback)
    end
end

function DungeonCityInfoPanel:onCallback()
    local plotId = self.data._info.plot
--    plotId = 301
    if plotId ~= 0 and plotId ~= nil and self.data.star == 0 then
        self:onClosePanelHandler()

        local function callback()
            local panel = self:getPanel(DungeonCityPanel.NAME)
            panel:show(self.data)
        end
        GuideManager:guideHideCallback(callback, self)

        GuideManager:trigger(plotId, true)
    else
        local panel = self:getPanel(DungeonCityPanel.NAME)
        panel:show(self.data)
        self:onClosePanelHandler()
    end
end


