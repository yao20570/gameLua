local GuideAction471 = class("GuideAction471", AreaClickAction)

function GuideAction471:ctor()
    GuideAction471.super.ctor(self)
    
    self.info = "挑战关卡四"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city4"
    
    self.callbackArg = true
end

function GuideAction471:onEnter(guide)
    GuideAction471.super.onEnter(self, guide)
end

return GuideAction471