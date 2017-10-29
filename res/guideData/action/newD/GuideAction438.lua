local GuideAction438 = class("GuideAction438", AreaClickAction)

function GuideAction438:ctor()
    GuideAction438.super.ctor(self)
    
    self.info = "立即挑战"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonCityPanel"
    self.widgetName = "fightBtn"
     self.delayTimePre= 0.5   
    
    self.isShowArrow = false
end

function GuideAction438:onEnter(guide)
    GuideAction438.super.onEnter(self, guide)
end

return GuideAction438