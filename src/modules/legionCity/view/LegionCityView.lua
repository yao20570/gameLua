
LegionCityView = class("LegionCityView", BasicView)

function LegionCityView:ctor(parent)
    LegionCityView.super.ctor(self, parent)
end

function LegionCityView:finalize()
    LegionCityView.super.finalize(self)
end

function LegionCityView:registerPanels()
    LegionCityView.super.registerPanels(self)

    require("modules.legionCity.panel.LegionCityPanel")
    self:registerPanel(LegionCityPanel.NAME, LegionCityPanel)

     require("modules.legionCity.panel.LegionTownPanel")
    self:registerPanel(LegionTownPanel.NAME, LegionTownPanel)

     require("modules.legionCity.panel.LegionCapitalPanel")
    self:registerPanel(LegionCapitalPanel.NAME, LegionCapitalPanel)

     require("modules.legionCity.panel.LegionImperialPanel")
    self:registerPanel(LegionImperialPanel.NAME, LegionImperialPanel)

    require("modules.legionCity.panel.LegionTanPanel")
    self:registerPanel(LegionTanPanel.NAME, LegionTanPanel)

    require("modules.legionCity.panel.LegionKingTanPanel")
    self:registerPanel(LegionKingTanPanel.NAME, LegionKingTanPanel)

end

function LegionCityView:initView()
    local panel = self:getPanel(LegionCityPanel.NAME)
    panel:show()
end

function LegionCityView:hideModuleHandler()
    local panel=self:getPanel(LegionImperialPanel.NAME)
    panel:removeFun()
     
    self:dispatchEvent(LegionCityEvent.HIDE_SELF_EVENT, {})
    
end


function LegionCityView:onUpdateTown(data)  
    local panel =self:getPanel(LegionTownPanel.NAME)
    panel:onUpdateTown(data)
end


function LegionCityView:onUpdateCapital(data)
    local panel=self:getPanel(LegionCapitalPanel.NAME)
    panel:onUpdateCapital(data)
end

function LegionCityView:onUpdateImperial(data)
    local panel= self:getPanel(LegionImperialPanel.NAME)
    panel:onUpdateImperial(data)
end

function LegionCityView:updateInfo(data)
    if data[2] == 47 then
        local panel = self:getPanel(LegionTownPanel.NAME)
        if panel ~= nil then 
            panel:updateInfo(data)
        end

    elseif data[2] == 36 then
        local panel = self:getPanel(LegionCapitalPanel.NAME)
        if panel ~= nil then 
            panel:updateInfo(data)
        end
    elseif data[2] == 55 then
        local panel = self:getPanel(LegionImperialPanel.NAME)
        if panel ~= nil then 
            panel:updateInfo(data)
        end
    end
end

function LegionCityView:updateRedPoint(data)
    local panel =self:getPanel(LegionCityPanel.NAME)
    panel:updateRedPoint(data)
end