local GuideAction440 = class("GuideAction440", AreaClickAction)

function GuideAction440:ctor()
    GuideAction440.super.ctor(self)
    
    self.info = "挑战关卡二"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city2"
    self.delayTime = 0.5 
    
    self.callbackArg = true
end

function GuideAction440:onEnter(guide)
    GuideAction440.super.onEnter(self, guide)
end

return GuideAction440