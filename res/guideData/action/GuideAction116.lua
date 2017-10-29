local GuideAction116 = class("GuideAction116", AreaClickAction)

function GuideAction116:ctor()
    GuideAction116.super.ctor(self)
    
    self.info = "一键上阵，战力快速提升"
    self.moduleName = ModuleName.EquipModule
    self.panelName = "EquipMainPanelNewPanel"
    self.widgetName = "yijianBtn"
    self.isShowArrow = false
    self.delayTime = 2.5
end

function GuideAction116:onEnter(guide)
    GuideAction116.super.onEnter(self, guide)
    local panel = guide:getPanel(ModuleName.EquipModule,"EquipMainPanelNewPanel")
    panel:show(2, "EquipHeroChangePanel")
end

return GuideAction116