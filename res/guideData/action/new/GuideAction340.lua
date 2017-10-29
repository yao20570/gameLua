local GuideAction340 = class("GuideAction340", AreaClickAction)

function GuideAction340:ctor()
    GuideAction340.super.ctor(self)
    
    self.info = "挑战关卡二"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city2"
    
    self.callbackArg = true
end

function GuideAction340:onEnter(guide)
    GuideAction340.super.onEnter(self, guide)
end

return GuideAction340