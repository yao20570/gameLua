local GuideAction441 = class("GuideAction441", AreaClickAction)

function GuideAction441:ctor()
    GuideAction441.super.ctor(self)
    
    self.info = "挑战关卡三"
    self.moduleName = ModuleName.DungeonModule
    self.panelName = "DungeonMapPanel"
    self.widgetName = "city3"
    
    self.callbackArg = true
end

function GuideAction441:onEnter(guide)
    GuideAction441.super.onEnter(self, guide)
end

return GuideAction441