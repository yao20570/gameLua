local GuideAction118 = class("GuideAction118", AreaClickAction)

function GuideAction118:ctor()
    GuideAction118.super.ctor(self)
    
    self.info = "摧毁敌军可获得步兵小队"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city5"
    
    self.callbackArg = true
    self.isShowArrow = false
    
end

function GuideAction118:onEnter(guide)
    GuideAction118.super.onEnter(self, guide)
end

return GuideAction118