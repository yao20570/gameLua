local GuideAction338 = class("GuideAction338", AreaClickAction)

function GuideAction338:ctor()
    GuideAction338.super.ctor(self)
    
    self.info = "立即挑战"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonCityPanel"
    self.widgetName = "fightBtn"
    
    self.isShowArrow = false
end

function GuideAction338:onEnter(guide)
    GuideAction338.super.onEnter(self, guide)
end

return GuideAction338