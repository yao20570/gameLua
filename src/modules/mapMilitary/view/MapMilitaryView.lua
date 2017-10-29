
MapMilitaryView = class("MapMilitaryView", BasicView)

function MapMilitaryView:ctor(parent)
    MapMilitaryView.super.ctor(self, parent)
end

function MapMilitaryView:finalize()
    MapMilitaryView.super.finalize(self)
end

function MapMilitaryView:registerPanels()
    MapMilitaryView.super.registerPanels(self)

    require("modules.mapMilitary.panel.MapMilitaryPanel")
    self:registerPanel(MapMilitaryPanel.NAME, MapMilitaryPanel)

    require("modules.mapMilitary.panel.MapMilitaryTaskPanel")
    self:registerPanel(MapMilitaryTaskPanel.NAME, MapMilitaryTaskPanel)

    require("modules.mapMilitary.panel.MapMilitaryCentralTargetPanel")
    self:registerPanel(MapMilitaryCentralTargetPanel.NAME, MapMilitaryCentralTargetPanel)
end

function MapMilitaryView:initView()
    local panel = self:getPanel(MapMilitaryPanel.NAME)
    panel:show()
end

function MapMilitaryView:openView()
    local panel = self:getPanel(MapMilitaryPanel.NAME)
    panel:show()
end

function MapMilitaryView:updateMilitary()
    local panel = self:getPanel(MapMilitaryTaskPanel.NAME)
    panel:updateUI()
end

function MapMilitaryView:onMapMilitaryPlayAnima(data)
    local panel = self:getPanel(MapMilitaryTaskPanel.NAME)
    panel:playGetAwardAnima(data)
end

--中原目标
function MapMilitaryView:plainschapterUpdate()
    local panel = self:getPanel(MapMilitaryCentralTargetPanel.NAME)
    panel:plainschapterUpdate()
end

function MapMilitaryView:onGetRoleInfo()
    local panel = self:getPanel(MapMilitaryPanel.NAME)
    panel:onGetRoleInfo()
end

function MapMilitaryView:updateRedPoint()
    local panel = self:getPanel(MapMilitaryPanel.NAME)
    panel:updateRedPoint()
end 